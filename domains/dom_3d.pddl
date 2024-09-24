;Header and description

(define (domain dom_3d)

;remove requirements that are not needed
(:requirements 
    :typing
    :negative-preconditions
    :durative-actions
    :numeric-fluents
    :equality
    :conditional-effects
    :derived-predicates
    :disjunctive-preconditions
)

(:types ;todo: enumerate types and their hierarchy here, e.g. car truck bus - vehicle
    train track driver - object
)

; un-comment following line if constants are needed
;(:constants )

(:predicates ;todo: define predicates here
    ; driver
    (idle ?d - driver)
    (driving ?d - driver ?t - train)

    ; train
    (ahead_aside ?t1 - train ?t2 - train)
    ; (ahead_bside ?t1 - train ?t2 - train)
    (serviced ?t - train)    
    (available ?t - train)
    (unoperated ?t - train)
    (operated ?t - train)
    (direction_aside ?t - train)
    (direction_bside ?t - train)
    
    ; object + track
    (train_at ?t - train ?r - track)

    ; track
    (in_yard ?r - track)
    (parking_allowed ?r - track)
    (service_allowed ?r - track)
    (track_connected ?r1 - track ?r2 - track)

)

(:functions
    ; train
    (train_length ?t - train)
    (order ?t - train)
    (train_entry_distance ?t - train)

    ; track
    (track_length ?r - track)
    (num_trains ?r - track)
    (track_entry_distance ?r - track)    
)

(:durative-action service_train
    :parameters (
        ?d - driver
        ?t - train
        ?r - track
    )
    :duration (= ?duration 30)
    :condition (and 
        (at start (and 
            (driving ?d ?t)
            (operated ?t)
            (train_at ?t ?r)
            (service_allowed ?r)
            (available ?t)
        ))
    )
    :effect (and 
        (at start (and
            (idle ?d) 
            (not (driving ?d ?t))
            (not (operated ?t))
            (not (available ?t))
        ))
        (at end (and 
            (available ?t) 
            (serviced ?t)
            (unoperated ?t)
            (not (direction_aside ?t))
            (not (direction_bside ?t))
        ))
    )
)


(:durative-action exit
    :parameters (
        ?d - driver
        ?t - train
        ?r - track
    )
    :duration (= ?duration 4)
    :condition (and 
        (at start (and 
            (driving ?d ?t)
            (operated ?t)
            (available ?t)
            (train_at ?t ?r)            
            (parking_allowed ?r)
        ))
    )
    :effect (and 
        (at start (and 
            (not (driving ?d ?t))
            (not (operated ?t))
            (not (available ?t))
            (not (direction_aside ?t))
            (not (direction_bside ?t))
        ))
        (at end (and
            (idle ?d)
            (unoperated ?t)
            (available ?t)
        ))
    )
)

(:durative-action enter_and_move_bside
    :parameters (
        ?d - driver
        ?t - train
        ?trackFrom - track
        ?trackTo - track
    )
    :duration (= ?duration 5)
    :condition (and 
        (at start (and
            (idle ?d)
            (unoperated ?t)
            (available ?t)
            (train_at ?t ?trackFrom)
            (>= (track_length ?trackTo) (train_length ?t))
            (in_yard ?trackTo)
            (track_connected ?trackTo ?trackFrom)
            (= (order ?t) (num_trains ?trackFrom))
        ))
    )
    :effect (and 
        (forall (?otherTrain - train) 
            (when 
                (and (at end (train_at ?otherTrain ?trackTo)) (at end (not (= ?otherTrain ?t))))
                (at end (increase (order ?otherTrain) 1))
            )
        )
        ; (when
        ;     (at end (parking_allowed ?trackTo))
        ;     (at end (parked ?t))
        ; )
        ; (when
        ;     (at end (not (parking_allowed ?trackTo)))
        ;     (at end (not (parked ?t)))
        ; )
        (at start (and
            (not (idle ?d))
            (not (unoperated ?t))
            (not (available ?t))
            (not (train_at ?t ?trackFrom))
            (decrease (track_length ?trackTo) (train_length ?t))
            (increase (num_trains ?trackTo) 1)
        ))
        (at end (and 
            (direction_bside ?t)
            (driving ?d ?t)
            (operated ?t)
            (available ?t)
            (train_at ?t ?trackTo)
            (increase (track_length ?trackFrom) (train_length ?t))
            (decrease (num_trains ?trackFrom) 1)
            (assign (order ?t) 1)
            (assign (train_entry_distance ?t) (track_entry_distance ?trackTo))
        ))
    )
)

(:durative-action move_bside
    :parameters (
        ?t - train
        ?trackFrom - track
        ?trackTo - track
    )
    :duration (= ?duration 1)
    :condition (and 
        (at start (and
            (available ?t)
            (train_at ?t ?trackFrom)
            (>= (track_length ?trackTo) (train_length ?t))
            (in_yard ?trackTo)
            (track_connected ?trackTo ?trackFrom)
            (= (order ?t) (num_trains ?trackFrom))
            (direction_bside ?t)
            (operated ?t)
        ))
    )
    :effect (and 
        (forall (?otherTrain - train) 
            (when 
                (and (at end (train_at ?otherTrain ?trackTo)) (at end (not (= ?otherTrain ?t))))
                (at end (increase (order ?otherTrain) 1))
            )
        )
        ; (when
        ;     (at end (parking_allowed ?trackTo))
        ;     (at end (parked ?t))
        ; )
        ; (when
        ;     (at end (not (parking_allowed ?trackTo)))
        ;     (at end (not (parked ?t)))
        ; )
        (at start (and
            (not (available ?t))
            (not (train_at ?t ?trackFrom))
            (decrease (track_length ?trackTo) (train_length ?t))
            (increase (num_trains ?trackTo) 1)
        ))
        (at end (and 
            (available ?t)
            (train_at ?t ?trackTo)
            (increase (track_length ?trackFrom) (train_length ?t))
            (decrease (num_trains ?trackFrom) 1)
            (assign (order ?t) 1)
            (assign (train_entry_distance ?t) (track_entry_distance ?trackTo))
        ))
    )
)

(:durative-action enter_and_move_aside
    :parameters (
        ?d - driver
        ?t - train
        ?trackFrom - track
        ?trackTo - track
    )
    :duration (= ?duration 5)
    :condition (and 
        (at start (and
            (idle ?d)
            (unoperated ?t)
            (available ?t)
            (train_at ?t ?trackFrom)
            (in_yard ?trackTo)
            (>= (track_length ?trackTo) (train_length ?t))
            (track_connected ?trackFrom ?trackTo)
            (= (order ?t) 1)
        ))
    )
    :effect (and 
        (forall (?otherTrain - train) 
            (when 
                (and (at end (train_at ?otherTrain ?trackFrom)) (at end (not (= ?otherTrain ?t))))
                (at end (decrease (order ?otherTrain) 1))
            )
        )
        ; (when
        ;     (at end (parking_allowed ?trackTo))
        ;     (at end (parked ?t))
        ; )
        ; (when
        ;     (at end (not (parking_allowed ?trackTo)))
        ;     (at end (not (parked ?t)))
        ; )
        (at start (and 
            (not (idle ?d))
            (not (unoperated ?t))
            (not (available ?t))
            (not (train_at ?t ?trackFrom))
            (decrease (track_length ?trackTo) (train_length ?t))
            (increase (num_trains ?trackTo) 1)
        ))
        (at end (and 
            (driving ?d ?t)
            (operated ?t)
            (direction_aside ?t)
            (available ?t)
            (train_at ?t ?trackTo)
            (increase (track_length ?trackFrom) (train_length ?t))
            (decrease (num_trains ?trackFrom) 1)
            (assign (order ?t) (num_trains ?trackTo))
            (assign (train_entry_distance ?t) (track_entry_distance ?trackTo))
        ))
    )
)

(:durative-action move_aside
    :parameters (
        ?t - train
        ?trackFrom - track
        ?trackTo - track
    )
    :duration (= ?duration 1)
    :condition (and 
        (at start (and
            (available ?t)
            (train_at ?t ?trackFrom)
            (in_yard ?trackTo)
            (>= (track_length ?trackTo) (train_length ?t))
            (track_connected ?trackFrom ?trackTo)
            (= (order ?t) 1)
            (direction_aside ?t)
            (operated ?t)
        ))
    )
    :effect (and 
        (forall (?otherTrain - train) 
            (when 
                (and (at end (train_at ?otherTrain ?trackFrom)) (at end (not (= ?otherTrain ?t))))
                (at end (decrease (order ?otherTrain) 1))
            )
        )
        ; (when
        ;     (at end (parking_allowed ?trackTo))
        ;     (at end (parked ?t))
        ; )
        ; (when
        ;     (at end (not (parking_allowed ?trackTo)))
        ;     (at end (not (parked ?t)))
        ; )
        (at start (and 
            (not (available ?t))
            (not (train_at ?t ?trackFrom))
            (decrease (track_length ?trackTo) (train_length ?t))
            (increase (num_trains ?trackTo) 1)
        ))
        (at end (and 
            (available ?t)
            (train_at ?t ?trackTo)
            (increase (track_length ?trackFrom) (train_length ?t))
            (decrease (num_trains ?trackFrom) 1)
            (assign (order ?t) (num_trains ?trackTo))
            (assign (train_entry_distance ?t) (track_entry_distance ?trackTo))
        ))
    )
)

(:derived (ahead_aside ?t1 - train ?t2 - train)
    (and
        (serviced ?t1)
        (serviced ?t2)
        ; (parked ?t1)
        ; (parked ?t2)
        (exists (?r - track) 
            (and (train_at ?t1 ?r) (parking_allowed ?r))
        )
        (exists (?r - track) 
            (and (train_at ?t2 ?r) (parking_allowed ?r))
        )
        (or
            (< (train_entry_distance ?t1) (train_entry_distance ?t2))
            (and (= (train_entry_distance ?t1) (train_entry_distance ?t2)) (< (order ?t1) (order ?t2)))
        )
    )
)








)