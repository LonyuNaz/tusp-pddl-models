;Header and description

(define (domain dom_5b)

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
    (driver_at ?d - driver ?r - track)
    
    ; train location
    (train_at ?t - train ?r - track) 

    ; ready to move
    (available ?t - train)

    ; collision preventing
    (connected ?r1 - track ?r2 - track)

    ; track types
    (service_allowed ?r - track)
    (parking_allowed ?r - track)

    ; goal state
    (serviced ?t - train)
    (ahead_aside ?t1 - train ?t2 - train)

)

(:functions 
    
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
        (at end (driver_at ?d ?r))
        ; block train
        (at start (not (available ?t)))
        (at end (available ?t))
    )
)

(:durative-action move_aside_empty
    :parameters (
        ?t - train
        ?from - track
        ?to - track
    )
    :duration (= ?duration 1)
    :condition (and    
        ; during
        (over all (operated ?t)) 
        ; statics
        (at start (connected ?to ?from))
        (at start (>= (track_length ?to) (train_length ?t)))
        ; changed in effects
        (at start (available ?t))
        (at start (train_at ?t ?from))
        (at start (= (num_trains ?to) 0))
        (at start (<= (aside_distance ?t)(astack_distance ?from)))
        (at start (< (num_trains ?to) (max_num_trains ?to)))
    )
    :effect (and 
        ; train approx. location update
        (at start (not (train_at ?t ?from)))
        (at end (train_at ?t ?to))
        ; destination track stack update
        (at start (assign (astack_distance ?to) 0))
        (at start (assign (bstack_distance ?to) (train_length ?t)))
        ; origin track stack update
        (at start (increase (astack_distance ?from) (train_length ?t)))
        ; number of trains update
        (at start (increase (num_trains ?to) 1))
        (at end (decrease (num_trains ?from) 1))
        ; train exact location update
        (at end (assign (aside_distance ?t) 0))
        ; block train
        (at start (not (available ?t)))
        (at end (available ?t))
    )
)

(:durative-action walk_and_enter_and_move_aside_empty
    :parameters (
        ?d - driver
        ?t - train
        ?driverFrom - track
        ?from - track
        ?to - track
    )
    :duration (= ?duration (+ (walking_duration ?driverFrom ?from) 3))
    :condition (and    
        ; driver
        (at start (driver_at ?d ?driverFrom))
        (at start (not (operated ?t)))
        (at start (idle ?d))
        ; statics
        (at start (connected ?to ?from))
        (at start (>= (track_length ?to) (train_length ?t)))
        ; changed in effects
        (at start (available ?t))
        (at start (train_at ?t ?from))
        (at start (= (num_trains ?to) 0))
        (at start (<= (aside_distance ?t)(astack_distance ?from)))
        (at start (< (num_trains ?to) (max_num_trains ?to)))
    )
    :effect (and 
        ; driver
        (at start (not (driver_at ?d ?driverFrom)))
        (at start (not (idle ?d)))
        (at end (operated ?t))
        (at end (driving ?d ?t))
        ; train approx. location update
        (at start (not (train_at ?t ?from)))
        (at end (train_at ?t ?to))
        ; destination track stack update
        (at start (assign (astack_distance ?to) 0))
        (at start (assign (bstack_distance ?to) (train_length ?t)))
        ; origin track stack update
        (at start (increase (astack_distance ?from) (train_length ?t)))
        ; number of trains update
        (at start (increase (num_trains ?to) 1))
        (at end (decrease (num_trains ?from) 1))
        ; train exact location update
        (at end (assign (aside_distance ?t) 0))
        ; block train
        (at start (not (available ?t)))
        (at end (available ?t))
    )
)

(:durative-action move_aside_occupied
    :parameters (
        ?t - train
        ?from - track
        ?to - track
    )
    :duration (= ?duration 1)
    :condition (and  
        ; during
        (over all (operated ?t))   
        ; statics
        (at start (connected ?to ?from))
        (at start (>= (track_length ?to) (train_length ?t)))
        ; changed in effects
        (at start (available ?t))
        (at start (train_at ?t ?from))
        (at start (> (num_trains ?to) 0))
        (at start (<= (+ (train_length ?t)(bstack_distance ?to)) (track_length ?to)))
        (at start (<= (aside_distance ?t)(astack_distance ?from)))
        (at start (< (num_trains ?to) (max_num_trains ?to)))
    )
    :effect (and 
        ; train approx. location update
        (at start (not (train_at ?t ?from)))
        (at end (train_at ?t ?to))
        ; train exact location update
        (at end (assign (aside_distance ?t) (+ (bstack_distance ?to) (train_length ?t))))
        ; destination track stack update
        (at start (increase (bstack_distance ?to) (train_length ?t)))
        ; origin track stack update
        (at start (increase (astack_distance ?from) (train_length ?t)))
        ; number of trains update
        (at start (increase (num_trains ?to) 1))
        (at end (decrease (num_trains ?from) 1))
        ; block train
        (at start (not (available ?t)))
        (at end (available ?t))
    )
)

(:durative-action walk_and_enter_and_move_aside_occupied
    :parameters (
        ?d - driver
        ?t - train
        ?driverFrom - track
        ?from - track
        ?to - track
    )
    :duration (= ?duration (+ (walking_duration ?driverFrom ?from) 3))
    :condition (and  
        ; driver
        (at start (driver_at ?d ?driverFrom))
        (at start (not (operated ?t)))
        (at start (idle ?d)) 
        ; statics
        (at start (connected ?to ?from))
        (at start (>= (track_length ?to) (train_length ?t)))
        ; changed in effects
        (at start (available ?t))
        (at start (train_at ?t ?from))
        (at start (> (num_trains ?to) 0))
        (at start (<= (+ (train_length ?t)(bstack_distance ?to)) (track_length ?to)))
        (at start (<= (aside_distance ?t)(astack_distance ?from)))
        (at start (< (num_trains ?to) (max_num_trains ?to)))
    )
    :effect (and 
        ; driver
        (at start (not (driver_at ?d ?driverFrom)))
        (at start (not (idle ?d)))
        (at end (operated ?t))
        (at end (driving ?d ?t))
        ; train approx. location update
        (at start (not (train_at ?t ?from)))
        (at end (train_at ?t ?to))
        ; train exact location update
        (at end (assign (aside_distance ?t) (+ (bstack_distance ?to) (train_length ?t))))
        ; destination track stack update
        (at start (increase (bstack_distance ?to) (train_length ?t)))
        ; origin track stack update
        (at start (increase (astack_distance ?from) (train_length ?t)))
        ; number of trains update
        (at start (increase (num_trains ?to) 1))
        (at end (decrease (num_trains ?from) 1))
        ; block train
        (at start (not (available ?t)))
        (at end (available ?t))
    )
)

(:durative-action move_bside_empty
    :parameters (
        ?t - train
        ?from - track
        ?to - track
    )
    :duration (= ?duration 1)
    :condition (and   
        ; during
        (over all (operated ?t)) 
        ; statics
        (over all (connected ?from ?to))
        (over all (>= (track_length ?to) (train_length ?t)))
        ; changed in effects  
        (at start (available ?t))
        (at start (train_at ?t ?from))
        (at start (= (num_trains ?to) 0))
        (at start (>= (+ (train_length ?t)(aside_distance ?t)) (bstack_distance ?from)))
        (at start (< (num_trains ?to) (max_num_trains ?to)))

    )
    :effect (and 
        ; train approx. location update
        (at start (not (train_at ?t ?from)))
        (at end (train_at ?t ?to))
        ; destination track stack update
        (at start (assign (astack_distance ?to) (- (track_length ?to)(train_length ?t))))
        (at start (assign (bstack_distance ?to) (track_length ?to)))
        ; origin track stack update
        (at start (decrease (bstack_distance ?from) (train_length ?t)))
        ; number of trains update
        (at start (increase (num_trains ?to) 1))
        (at end (decrease (num_trains ?from) 1))
        ; train exact location update
        (at end (assign (aside_distance ?t) (- (track_length ?to)(train_length ?t))))
        ; block train
        (at start (not (available ?t)))
        (at end (available ?t))
    )
)

(:durative-action walk_and_enter_and_move_bside_empty
    :parameters (
        ?d - driver
        ?t - train
        ?driverFrom - track
        ?from - track
        ?to - track
    )
    :duration (= ?duration (+ (walking_duration ?driverFrom ?from) 3))
    :condition (and   
        ; driver
        (at start (driver_at ?d ?driverFrom))
        (at start (not (operated ?t)))
        (at start (idle ?d))  
        ; statics
        (over all (connected ?from ?to))
        (over all (>= (track_length ?to) (train_length ?t)))
        ; changed in effects  
        (at start (available ?t))
        (at start (train_at ?t ?from))
        (at start (= (num_trains ?to) 0))
        (at start (>= (+ (train_length ?t)(aside_distance ?t)) (bstack_distance ?from)))
        (at start (< (num_trains ?to) (max_num_trains ?to)))

    )
    :effect (and 
        ; driver
        (at start (not (driver_at ?d ?driverFrom)))
        (at start (not (idle ?d)))
        (at end (operated ?t))
        (at end (driving ?d ?t))
        ; train approx. location update
        (at start (not (train_at ?t ?from)))
        (at end (train_at ?t ?to))
        ; destination track stack update
        (at start (assign (astack_distance ?to) (- (track_length ?to)(train_length ?t))))
        (at start (assign (bstack_distance ?to) (track_length ?to)))
        ; origin track stack update
        (at start (decrease (bstack_distance ?from) (train_length ?t)))
        ; number of trains update
        (at start (increase (num_trains ?to) 1))
        (at end (decrease (num_trains ?from) 1))
        ; train exact location update
        (at end (assign (aside_distance ?t) (- (track_length ?to)(train_length ?t))))
        ; block train
        (at start (not (available ?t)))
        (at end (available ?t))
    )
)

(:durative-action move_bside_occupied
    :parameters (
        ?t - train
        ?from - track
        ?to - track
    )
    :duration (= ?duration 1)
    :condition (and 
        ; during
        (over all (operated ?t)) 
        ; statics
        (at start (connected ?from ?to))
        (at start (>= (track_length ?to) (train_length ?t)))
        ; changed in effects 
        (at start (available ?t))
        (at start (train_at ?t ?from))
        (at start (> (num_trains ?to) 0))
        (at start (>= (astack_distance ?to) (train_length ?t)))
        (at start (>= (+ (train_length ?t)(aside_distance ?t)) (bstack_distance ?from)))
        (at start (< (num_trains ?to) (max_num_trains ?to)))
    )
    :effect (and 
        ; train approx. location update
        (at start (not (train_at ?t ?from)))
        (at end (train_at ?t ?to))
        ; train exact location update
        (at end (assign (aside_distance ?t) (- (astack_distance ?to) (train_length ?t))))
        ; destination track stack update
        (at start (decrease (astack_distance ?to) (train_length ?t)))
        ; origin track stack update
        (at start (decrease (bstack_distance ?from) (train_length ?t)))
        ; number of trains update
        (at start (increase (num_trains ?to) 1))
        (at end (decrease (num_trains ?from) 1))
        ; block train
        (at start (not (available ?t)))
        (at end (available ?t))
    )
)

(:durative-action walk_and_enter_and_move_bside_occupied
    :parameters (
        ?d - driver
        ?t - train
        ?driverFrom - track
        ?from - track
        ?to - track
    )
    :duration (= ?duration (+ (walking_duration ?driverFrom ?from) 3))
    :condition (and 
        ; driver
        (at start (driver_at ?d ?driverFrom))
        (at start (not (operated ?t)))
        (at start (idle ?d))  
        ; statics
        (at start (connected ?from ?to))
        (at start (>= (track_length ?to) (train_length ?t)))
        ; changed in effects 
        (at start (available ?t))
        (at start (train_at ?t ?from))
        (at start (> (num_trains ?to) 0))
        (at start (>= (astack_distance ?to) (train_length ?t)))
        (at start (>= (+ (train_length ?t)(aside_distance ?t)) (bstack_distance ?from)))
        (at start (< (num_trains ?to) (max_num_trains ?to)))
    )
    :effect (and 
        ; driver
        (at start (not (driver_at ?d ?driverFrom)))
        (at start (not (idle ?d)))
        (at end (operated ?t))
        (at end (driving ?d ?t))
        ; train approx. location update
        (at start (not (train_at ?t ?from)))
        (at end (train_at ?t ?to))
        ; train exact location update
        (at end (assign (aside_distance ?t) (- (astack_distance ?to) (train_length ?t))))
        ; destination track stack update
        (at start (decrease (astack_distance ?to) (train_length ?t)))
        ; origin track stack update
        (at start (decrease (bstack_distance ?from) (train_length ?t)))
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
                (and (parking_allowed ?r) (train_at ?t1 ?r) (train_at ?t2 ?r) (< (aside_distance ?t1) (aside_distance ?t2)))
            )
        )
    )
)



)