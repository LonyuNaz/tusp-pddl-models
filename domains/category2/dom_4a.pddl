;Header and description

(define (domain dom_4a)

;remove requirements that are not needed
(:requirements 
    :typing
    :negative-preconditions
    :durative-actions
    :numeric-fluents
    :equality
    :conditional-effects
    :disjunctive-preconditions
    :derived-predicates
)


(:types ;todo: enumerate types and their hierarchy here, e.g. car truck bus - vehicle
    train track driver - object
)


(:predicates ;todo: define predicates here
   
    ; driver
    (idle ?d - driver)
    (driving ?d - driver ?t - train)
    (operated ?t - train)
    (exit_allowed ?r - track)

    ; train location
    (train_at ?t - train ?r - track) 

    ; ready to move
    (available ?t - train)
    (direction_aside ?t - train)
    (direction_bside ?t - train)

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


(:durative-action exit
    :parameters (
        ?d - driver
        ?t - train
        ?r - track
    )
    :duration (= ?duration 3)
    :condition (and 
        (at start (available ?t))
        ; static
        (at start (exit_allowed ?r))
        ; other
        (at start (operated ?t))
        (at start (driving ?d ?t))
        (over all (train_at ?t ?r))
    )
    :effect (and 
        (at start  (not (operated ?t)))
        (at start (not (driving ?d ?t)))
        (at end (idle ?d))
        ; block train
        (at start (not (available ?t)))
        (at end (available ?t))
        ; direction
        (at end (not (direction_aside ?t)))
        (at end (not (direction_aside ?t)))
    )
)

(:durative-action move_aside
    :parameters (
        ?t - train
        ?from - track
        ?to - track
    )
    :duration (= ?duration 1)
    :condition (and     
        ; direction
        (over all (not (direction_bside ?t)))
        ; driver
        (over all (operated ?t))
        ; statics
        (at start (connected ?to ?from))
        (at start (>= (track_length ?to) (train_length ?t)))
        ; changed in effects
        (at start (available ?t))
        (at start (train_at ?t ?from))
        (at start (< (num_trains ?to) (max_num_trains ?to)))
        (at start (= (order ?t) 1))
    )
    :effect (and 
        ; direction
        (at start (direction_aside ?t))
        ; update new order
        (at end (assign (order ?t) (num_trains ?to)))
        ; update trains on origin track
        (forall (?otherTrain - train) 
            (when 
                (and (at end (train_at ?otherTrain ?from)) (at end (not (= ?otherTrain ?t))))
                (at end (decrease (order ?otherTrain) 1))
            )
        )
        ; update track lengths
        (at start (decrease (track_length ?to) (train_length ?t)))
        (at end (increase (track_length ?from) (train_length ?t)))
        ; train approx. location update
        (at start (not (train_at ?t ?from)))
        (at end (train_at ?t ?to))
        ; number of trains update
        (at start (increase (num_trains ?to) 1))
        (at end (decrease (num_trains ?from) 1))
        ; block train
        (at start (not (available ?t)))
        (at end (available ?t))
    )
)

(:durative-action enter_and_move_aside
    :parameters (
        ?d - driver
        ?t - train
        ?from - track
        ?to - track
    )
    :duration (= ?duration 5)
    :condition (and     
        ; driver
        (at start (not (operated ?t)))
        (at start (idle ?d))
        ; statics
        (at start (connected ?to ?from))
        (at start (>= (track_length ?to) (train_length ?t)))
        ; changed in effects
        (at start (available ?t))
        (at start (train_at ?t ?from))
        (at start (< (num_trains ?to) (max_num_trains ?to)))
        (at start (= (order ?t) 1))
    )
    :effect (and 
        ; direction
        (at start (direction_aside ?t))
        (at start (not (direction_bside ?t)))
        ; driver
        (at start (not (idle ?d)))
        (at end (operated ?t))
        (at end (driving ?d ?t))
        ; update new order
        (at end (assign (order ?t) (num_trains ?to)))
        ; update trains on origin track
        (forall (?otherTrain - train) 
            (when 
                (and (at end (train_at ?otherTrain ?from)) (at end (not (= ?otherTrain ?t))))
                (at end (decrease (order ?otherTrain) 1))
            )
        )
        ; update track lengths
        (at start (decrease (track_length ?to) (train_length ?t)))
        (at end (increase (track_length ?from) (train_length ?t)))
        ; train approx. location update
        (at start (not (train_at ?t ?from)))
        (at end (train_at ?t ?to))
        ; number of trains update
        (at start (increase (num_trains ?to) 1))
        (at end (decrease (num_trains ?from) 1))
        ; block train
        (at start (not (available ?t)))
        (at end (available ?t))
    )
)

(:durative-action turn_and_move_aside
    :parameters (
        ?t - train
        ?from - track
        ?to - track
    )
    :duration (= ?duration 4)
    :condition (and     
        ; driver
        (over all (operated ?t))
        ; turn constraints
        (at start (exit_allowed ?from))
        (at start (direction_bside ?t))
        (at start (not (direction_aside ?t)))
        ; statics
        (at start (connected ?to ?from))
        (at start (>= (track_length ?to) (train_length ?t)))
        ; changed in effects
        (at start (available ?t))
        (at start (train_at ?t ?from))
        (at start (< (num_trains ?to) (max_num_trains ?to)))
        (at start (= (order ?t) 1))
    )
    :effect (and 
        ; direction
        (at start (direction_aside ?t))
        (at end (not (direction_bside ?t)))
        ; update new order
        (at end (assign (order ?t) (num_trains ?to)))
        ; update trains on origin track
        (forall (?otherTrain - train) 
            (when 
                (and (at end (train_at ?otherTrain ?from)) (at end (not (= ?otherTrain ?t))))
                (at end (decrease (order ?otherTrain) 1))
            )
        )
        ; update track lengths
        (at start (decrease (track_length ?to) (train_length ?t)))
        (at end (increase (track_length ?from) (train_length ?t)))
        ; train approx. location update
        (at start (not (train_at ?t ?from)))
        (at end (train_at ?t ?to))
        ; number of trains update
        (at start (increase (num_trains ?to) 1))
        (at end (decrease (num_trains ?from) 1))
        ; block train
        (at start (not (available ?t)))
        (at end (available ?t))
    )
)

(:durative-action move_bside
    :parameters (
        ?t - train
        ?from - track
        ?to - track
    )
    :duration (= ?duration 1)
    :condition (and   
        ; direction
        (over all (not (direction_aside ?t)))
        ; driver
        (over all (operated ?t))
        ; statics
        (at start (connected ?from ?to))
        (at start (>= (track_length ?to) (train_length ?t)))
        ; changed in effects  
        (at start (available ?t))
        (at start (train_at ?t ?from))
        (at start (= (order ?t) (num_trains ?from)))
        (at start (< (num_trains ?to) (max_num_trains ?to)))

    )
    :effect (and 
        ; direction
        (at start (direction_bside ?t))
        ; update new order
        (at end (assign (order ?t) 1))
        ; update trains on origin track
        (forall (?otherTrain - train) 
            (when 
                (and (at end (train_at ?otherTrain ?to)) (at end (not (= ?otherTrain ?t))))
                (at end (increase (order ?otherTrain) 1))
            )
        )
        ; update track lengths
        (at start (decrease (track_length ?to) (train_length ?t)))
        (at end (increase (track_length ?from) (train_length ?t)))
        ; train approx. location update
        (at start (not (train_at ?t ?from)))
        (at end (train_at ?t ?to))
        ; number of trains update
        (at start (increase (num_trains ?to) 1))
        (at end (decrease (num_trains ?from) 1))
        ; block train
        (at start (not (available ?t)))
        (at end (available ?t))
    )
)

(:durative-action enter_and_move_bside
    :parameters (
        ?d - driver
        ?t - train
        ?from - track
        ?to - track
    )
    :duration (= ?duration 5)
    :condition (and   
        ; driver
        (at start (not (operated ?t)))
        (at start (idle ?d))
        ; statics
        (at start (connected ?from ?to))
        (at start (>= (track_length ?to) (train_length ?t)))
        ; changed in effects  
        (at start (available ?t))
        (at start (train_at ?t ?from))
        (at start (= (order ?t) (num_trains ?from)))
        (at start (< (num_trains ?to) (max_num_trains ?to)))

    )
    :effect (and 
        ; direction
        (at start (direction_bside ?t))
        (at start (not (direction_aside ?t)))
        ; driver
        (at start (not (idle ?d)))
        (at end (operated ?t))
        (at end (driving ?d ?t))
        ; update new order
        (at end (assign (order ?t) 1))
        ; update trains on origin track
        (forall (?otherTrain - train) 
            (when 
                (and (at end (train_at ?otherTrain ?to)) (at end (not (= ?otherTrain ?t))))
                (at end (increase (order ?otherTrain) 1))
            )
        )
        ; update track lengths
        (at start (decrease (track_length ?to) (train_length ?t)))
        (at end (increase (track_length ?from) (train_length ?t)))
        ; train approx. location update
        (at start (not (train_at ?t ?from)))
        (at end (train_at ?t ?to))
        ; number of trains update
        (at start (increase (num_trains ?to) 1))
        (at end (decrease (num_trains ?from) 1))
        ; block train
        (at start (not (available ?t)))
        (at end (available ?t))
    )
)

(:durative-action turn_and_move_bside
    :parameters (
        ?t - train
        ?from - track
        ?to - track
    )
    :duration (= ?duration 4)
    :condition (and   
        ; driver
        (over all (operated ?t))
        ; turn constraints
        (at start (exit_allowed ?from))
        (at start (direction_aside ?t))
        (at start (not (direction_bside ?t)))
        ; statics
        (over all (connected ?from ?to))
        (over all (>= (track_length ?to) (train_length ?t)))
        ; changed in effects  
        (at start (available ?t))
        (at start (train_at ?t ?from))
        (at start (= (order ?t) (num_trains ?from)))
        (at start (< (num_trains ?to) (max_num_trains ?to)))

    )
    :effect (and 
        ; direction
        (at start (direction_bside ?t))
        (at end (not (direction_aside ?t)))
        ; update new order
        (at end (assign (order ?t) 1))
        ; update trains on origin track
        (forall (?otherTrain - train) 
            (when 
                (and (at end (train_at ?otherTrain ?to)) (at end (not (= ?otherTrain ?t))))
                (at end (increase (order ?otherTrain) 1))
            )
        )
        ; update track lengths
        (at start (decrease (track_length ?to) (train_length ?t)))
        (at end (increase (track_length ?from) (train_length ?t)))
        ; train approx. location update
        (at start (not (train_at ?t ?from)))
        (at end (train_at ?t ?to))
        ; number of trains update
        (at start (increase (num_trains ?to) 1))
        (at end (decrease (num_trains ?from) 1))
        ; block train
        (at start (not (available ?t)))
        (at end (available ?t))
    )
)

(:durative-action service_train
    :parameters (
        ?t - train
        ?r - track
    )
    :duration (= ?duration 30)
    :condition (and 
        (at start (not (serviced ?t)))
        ; static
        (at start (service_allowed ?r))
        ; changed in effect
        (at start (available ?t))
        (at start (not (operated ?t)))
        ; other
        (over all (train_at ?t ?r))
    )
    :effect (and 
        ; block trains
        (at start (not (available ?t)))
        (at end (available ?t))
        (at end (serviced ?t))
    )
)


(:derived (ahead_aside ?t1 - train ?t2 - train)
    (and
        (serviced ?t1)
        (serviced ?t2)
        (or
            (exists (?r1 - track ?r2 - track) 
                (and (not (= ?r1 ?r2)) (parking_allowed ?r1) (parking_allowed ?r2) (train_at ?t1 ?r1) (train_at ?t2 ?r2) (<= (entry_distance ?r1) (entry_distance ?r2)))
            )
            (exists (?r - track) 
                (and (parking_allowed ?r) (train_at ?t1 ?r) (train_at ?t2 ?r) (< (order ?t1) (order ?t2)))
            )
        )
    )
)


)