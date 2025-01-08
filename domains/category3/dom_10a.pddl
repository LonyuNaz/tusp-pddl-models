;Header and description

(define (domain dom_3c)

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
    train track driver - object
)


(:predicates ;todo: define predicates here
    
    ; driver
    (idle ?d - driver)
    (driving ?d - driver ?t - train)
    (operated ?t - train)
    (exit_allowed ?r - track)
    (driver_at ?d - driver ?r - track)
   
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

    (walking_duration ?r1 - track ?r2 - track)

)

(:action exit
    :parameters (
        ?d - driver
        ?t - train
        ?r - track
    )
    :precondition (and 
        (available ?t)
        (driving ?d ?t)
        (operated ?t)
        (train_at ?t ?r)
        (exit_allowed ?r)
    )
    :effect (and 
        (increase (total-cost) 2)
        (idle ?d)
        (not (driving ?d ?t))
        (not (operated ?t))
        (driver_at ?d ?r)
    )
)

(:action walk_and_enter
    :parameters (
        ?d - driver
        ?t - train
        ?from - track
        ?to - track
    )
    :precondition (and 
        (available ?t)
        (driver_at ?d ?from)
        (idle ?d)
        (not (operated ?t))
        (train_at ?t ?to)
        (or
            (<= (aside_distance ?t)(astack_distance ?to))
            (>= (+ (train_length ?t)(aside_distance ?t)) (bstack_distance ?to))
        )
    )
    :effect (and 
        (increase (total-cost) (+ (walking_duration ?from ?to) 2))
        (not (idle ?d))
        (not (driver_at ?d ?from))
        (driving ?d ?t)
        (operated ?t)
    )
)

(:action move_aside
    :parameters (
        ?t - train
        ?from - track
        ?to - track
    )
    :precondition (and
        (operated ?t)
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
        ; cost
        (when (direction_bside ?t) (increase (total-cost) 4))
        (when (not (direction_bside ?t)) (increase (total-cost) 1))
        (not (direction_bside ?t))
        (direction_aside ?t)
        ; train approx. location update
        (not (train_at ?t ?from))
        (train_at ?t ?to)
        ; destination track stack update
        (when (= (num_trains ?to) 0) (and
            (assign (astack_distance ?to) 0)
            (assign (bstack_distance ?to) (train_length ?t))
        ))
        (when (> (num_trains ?to) 0) 
            (increase (bstack_distance ?to) (train_length ?t))
        )
        ; origin track stack update
        (increase (astack_distance ?from) (train_length ?t))
        ; number of trains update
        (increase (num_trains ?to) 1)
        (decrease (num_trains ?from) 1)
        ; train exact location update
        (assign (aside_distance ?t) 0)
    )
)

(:action move_bside
    :parameters (
        ?t - train
        ?from - track
        ?to - track
    )
    :precondition (and  
        (operated ?t)
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
        (when (direction_aside ?t) (increase (total-cost) 4))
        (when (not (direction_aside ?t)) (increase (total-cost) 1))
        (not (direction_aside ?t))
        (direction_bside ?t)
        ; train approx. location update
        (not (train_at ?t ?from))
        (train_at ?t ?to)
        ; destination track stack update
        (when (= (num_trains ?to) 0) (and
            (assign (astack_distance ?to) (- (track_length ?to)(train_length ?t)))
            (assign (bstack_distance ?to) (track_length ?to))
        ))
        (when (> (num_trains ?to) 0) 
            (decrease (astack_distance ?to) (train_length ?t))
        )
        ; origin track stack update
        (decrease (bstack_distance ?from) (train_length ?t))
        ; number of trains update
        (increase (num_trains ?to) 1)
        (decrease (num_trains ?from) 1)
        ; train exact location update
        (assign (aside_distance ?t) (- (track_length ?to)(train_length ?t)))
    )
)

(:action service_train
    :parameters (
        ?d - driver
        ?t - train
        ?r - track
    )
    :precondition (and 
        (not (serviced ?t))
        (driving ?d ?t)
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
        (not (operated ?t))
        (idle ?d)
        (not (driving ?d ?t))
    
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
            (and (= ?r1 ?r2) (< (aside_distance ?t1) (aside_distance ?t2)))
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