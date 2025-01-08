;Header and description

(define (domain dom_1a)

;remove requirements that are not needed
(:requirements 
    :typing
    :negative-preconditions
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
    
    (total-cost)

    ; train location
    (aside_distance ?t - train)
    (train_length ?t - train)

    ; track capacity
    (track_length ?r - track)
    (astack_distance ?r - track)
    (bstack_distance ?r - track)
    (max_num_trains ?r - track)

    ; readability
    (num_trains ?r - track)

    ; goal state
    (entry_distance ?r - track)

)

(:action move_aside
    :parameters (
        ?t - train
        ?from - track
        ?to - track
    )
    :precondition (and     
        ; statics
        (connected ?to ?from)
        (>= (track_length ?to) (train_length ?t))
        ; changed in effects
        (available ?t)
        (train_at ?t ?from)
        (or
            (= (num_trains ?to) 0)
            (and (> (num_trains ?to) 0) (<= (+ (train_length ?t)(bstack_distance ?to)) (track_length ?to)))
        )
        (<= (aside_distance ?t)(astack_distance ?from))
        (< (num_trains ?to) (max_num_trains ?to))
    )
    :effect (and 
        (increase (total-cost) 1)
        ; train approx. location update
        (not (train_at ?t ?from))
        (train_at ?t ?to)
        ; destination track stack update
        (when (= (num_trains ?to) 0) (and
            (assign (aside_distance ?t) 0)
            (assign (astack_distance ?to) 0)
            (assign (bstack_distance ?to) (train_length ?t))
        ))
        (when (> (num_trains ?to) 0) (and
            (assign (aside_distance ?t) (bstack_distance ?to))
            (increase (bstack_distance ?to) (train_length ?t))
        ))
        ; origin track stack update
        (increase (astack_distance ?from) (train_length ?t))
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
        ; statics
        (connected ?from ?to)
        (>= (track_length ?to) (train_length ?t))
        ; changed in effects  
        (available ?t)
        (train_at ?t ?from)
        (or
            (= (num_trains ?to) 0)
            (and (> (num_trains ?to) 0) (>= (astack_distance ?to) (train_length ?t)))
        )
        (>= (+ (train_length ?t)(aside_distance ?t)) (bstack_distance ?from))
        (< (num_trains ?to) (max_num_trains ?to))

    )
    :effect (and 
        (increase (total-cost) 1)
        ; train approx. location update
        (not (train_at ?t ?from))
        (train_at ?t ?to)
        ; destination track stack update
        (when (= (num_trains ?to) 0) (and
            (assign (aside_distance ?t) (- (track_length ?to)(train_length ?t)))
            (assign (astack_distance ?to) (- (track_length ?to)(train_length ?t)))
            (assign (bstack_distance ?to) (track_length ?to))
        ))
        (when (> (num_trains ?to) 0) (and
            (assign (aside_distance ?t) (- (astack_distance ?to) (train_length ?t)))
            (decrease (astack_distance ?to) (train_length ?t))
        ))
        ; origin track stack update
        (decrease (bstack_distance ?from) (train_length ?t))
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
        (not (serviced ?t))
        ; static
        (service_allowed ?r)
        ; changed in effect
        (available ?t)
        ; other
        (train_at ?t ?r)
    )
    :effect (and 
        ; block trains
        (serviced ?t)
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
                (and (parking_allowed ?r) (train_at ?t1 ?r) (train_at ?t2 ?r) (< (aside_distance ?t1) (aside_distance ?t2)))
            )
        )
    )
)


)