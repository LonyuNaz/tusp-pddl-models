;Header and description

(define (domain dom_2a)

;remove requirements that are not needed
(:requirements 
    :typing
    :negative-preconditions
    :numeric-fluents
    :equality
    :conditional-effects
    :disjunctive-preconditions
    :derived-predicates
    :action-costs
)


(:types ;todo: enumerate types and their hierarchy here, e.g. car truck bus - vehicle
    train track - object
)


(:predicates ;todo: define predicates here
   
    ; train location
    (train_at ?t - train ?r - track) 

    ; ready to move
    (available ?t - train)
    (direction_aside ?t - train)
    (direction_bside ?t - train)
    (exit_allowed ?r - track)

    ; collision preventing
    (connected ?r1 - track ?r2 - track)

    ; track types
    (service_allowed ?r - track)
    (parking_allowed ?r - track)

    ; goal state
    (serviced ?t - train)
    (ahead_aside ?t1 - train ?t2 - train)
    (parking_pair ?t1 - train ?t2 - train)

)

(:functions 
    ; cost
    (total-cost)
    
    ; train location
    (train_length ?t - train)
    (order ?t - train)

    ; track capacity
    (track_length ?r - track)
    (max_num_trains ?r - track)

    ; readability
    (num_trains ?r - track)

    ; goal state
    (entry_distance ?r - track)
)

(:action turn_aside
    :parameters (
        ?t - train
        ?r - track
    )
    :precondition (and 
        (available ?t)
        (train_at ?t ?r)
        (exit_allowed ?r)
        (direction_bside ?t)
    )
    :effect (and 
        (increase (total-cost) 3)
        (direction_aside ?t)
        (not (direction_bside ?t))
    )
)

(:action turn_bside
    :parameters (
        ?t - train
        ?r - track
    )
    :precondition (and 
        (available ?t)
        (train_at ?t ?r)
        (exit_allowed ?r)
        (direction_aside ?t)
    )
    :effect (and 
        (increase (total-cost) 3)
        (direction_bside ?t)
        (not (direction_aside ?t))
    )
)


(:action move_aside
    :parameters (
        ?t - train
        ?from - track
        ?to - track
    )
    :precondition (and 
        (available ?t)
        ; direction
        (not (direction_bside ?t))    
        ; statics
        (connected ?to ?from)
        (>= (track_length ?to) (train_length ?t))
        ; changed in effects
        (train_at ?t ?from)
        (< (num_trains ?to) (max_num_trains ?to))
        (= (order ?t) 1)
    )
    :effect (and 
        (direction_aside ?t)
        ; cost
        (increase (total-cost) 1)
        ; update new order
        (assign (order ?t) (num_trains ?to))
        ; update trains on origin track
        (forall (?otherTrain - train) 
            (when 
                (and (train_at ?otherTrain ?from) (not (= ?otherTrain ?t)))
                (decrease (order ?otherTrain) 1)
            )
        )
        ; update track lengths
        (decrease (track_length ?to) (train_length ?t))
        (increase (track_length ?from) (train_length ?t))
        ; train approx. location update
        (not (train_at ?t ?from))
        (train_at ?t ?to)
        ; number of trains update
        (increase (num_trains ?to) 1)
        (decrease (num_trains ?from) 1)
    )
)

(:action move_bside
    :parameters (
        ?t - train
        ?from - track
        ?to - track
    )
    :precondition (and  
        (available ?t) 
        ; direction
        (not (direction_aside ?t))
        ; statics
        (connected ?from ?to)
        (>= (track_length ?to) (train_length ?t))
        ; changed in effects  
        (train_at ?t ?from)
        (= (order ?t) (num_trains ?from))
        (< (num_trains ?to) (max_num_trains ?to))

    )
    :effect (and 
        ; direction
        (direction_bside ?t)
        ; cost
        (increase (total-cost) 1)
        ; update new order
        (assign (order ?t) 1)
        ; update trains on origin track
        (forall (?otherTrain - train) 
            (when 
                (and (train_at ?otherTrain ?to) (not (= ?otherTrain ?t)))
                (increase (order ?otherTrain) 1)
            )
        )
        ; update track lengths
        (decrease (track_length ?to) (train_length ?t))
        (increase (track_length ?from) (train_length ?t))
        ; train approx. location update
        (not (train_at ?t ?from))
        (train_at ?t ?to)
        ; number of trains update
        (increase (num_trains ?to) 1)
        (decrease (num_trains ?from) 1)
    )
)

(:action service_train
    :parameters (
        ?t - train
        ?r - track
    )
    :precondition (and 
        (available ?t)
        (not (serviced ?t))
        ; static
        (service_allowed ?r)
        ; other
        (train_at ?t ?r)
    )
    :effect (and 
        ; block trains
        (serviced ?t)
        (not (direction_aside ?t))
        (not (direction_bside ?t))
    )
)

(:action park
    :parameters (
        ?t1 - train
        ?t2 - train
        ?r1 - track
        ?r2 - track
    )
    :precondition (and 
        (parking_pair ?t1 ?t2)
        (not (ahead_aside ?t1 ?t2))
        (serviced ?t1)
        (serviced ?t2)
        (parking_allowed ?r1)
        (parking_allowed ?r2)
        (train_at ?t1 ?r1)
        (train_at ?t2 ?r2)
        (or
            (and (= ?r1 ?r2) (< (order ?t1) (order ?t2)))
            (and (not (= ?r1 ?r2)) (<= (entry_distance ?r1) (entry_distance ?r2)))
        )
    )
    :effect (and 
        (ahead_aside ?t1 ?t2)
        (not (available ?t1))
        (not (available ?t2))
    )
)


)