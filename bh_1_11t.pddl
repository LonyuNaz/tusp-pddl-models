(define
(problem bh_1_11t)
(:domain dom_1a)
(:objects

	train_slt40 - train
	train_slt41 - train
	train_slt42 - train
	train_slt43 - train
	train_slt44 - train
	train_slt45 - train
	train_slt46 - train
	train_slt47 - train
	train_slt48 - train
	train_slt49 - train
	train_slt50 - train
	track_52 - track
	track_53 - track
	track_54 - track
	track_55 - track
	track_56 - track
	track_57 - track
	track_58 - track
	track_59 - track
	track_60 - track
	track_61_service - track
	track_62_service - track
	track_63 - track
	track_entry - track

)

(:init

	(= (total-cost) 0)

	; track: 52
	; ====================
	(= (entry_distance track_52) 1)
	(parking_allowed track_52)
	(exit_allowed track_52)
	(= (max_num_trains track_52) 100)
	(= (track_length track_52) 400)
	(= (num_trains track_52) 0)

	; track: 53
	; ====================
	(= (entry_distance track_53) 1)
	(parking_allowed track_53)
	(exit_allowed track_53)
	(= (max_num_trains track_53) 100)
	(= (track_length track_53) 400)
	(= (num_trains track_53) 0)

	; track: 54
	; ====================
	(= (entry_distance track_54) 1)
	(parking_allowed track_54)
	(exit_allowed track_54)
	(= (max_num_trains track_54) 100)
	(= (track_length track_54) 320)
	(= (num_trains track_54) 0)

	; track: 55
	; ====================
	(= (entry_distance track_55) 1)
	(parking_allowed track_55)
	(exit_allowed track_55)
	(= (max_num_trains track_55) 100)
	(= (track_length track_55) 320)
	(= (num_trains track_55) 0)

	; track: 56
	; ====================
	(= (entry_distance track_56) 1)
	(parking_allowed track_56)
	(exit_allowed track_56)
	(= (max_num_trains track_56) 100)
	(= (track_length track_56) 160)
	(= (num_trains track_56) 0)

	; track: 57
	; ====================
	(= (entry_distance track_57) 1)
	(parking_allowed track_57)
	(exit_allowed track_57)
	(= (max_num_trains track_57) 100)
	(= (track_length track_57) 160)
	(= (num_trains track_57) 0)

	; track: 58
	; ====================
	(= (entry_distance track_58) 1)
	(parking_allowed track_58)
	(exit_allowed track_58)
	(= (max_num_trains track_58) 100)
	(= (track_length track_58) 160)
	(= (num_trains track_58) 0)

	; track: 59
	; ====================
	(= (entry_distance track_59) 1)
	(parking_allowed track_59)
	(exit_allowed track_59)
	(= (max_num_trains track_59) 100)
	(= (track_length track_59) 240)
	(= (num_trains track_59) 0)

	; track: 60
	; ====================
	(= (entry_distance track_60) 2)
	(parking_allowed track_60)
	(exit_allowed track_60)
	(= (max_num_trains track_60) 100)
	(= (track_length track_60) 240)
	(= (num_trains track_60) 0)

	; track: 61_service
	; ====================
	(= (entry_distance track_61_service) 2)
	(service_allowed track_61_service)
	(exit_allowed track_61_service)
	(= (max_num_trains track_61_service) 1)
	(= (track_length track_61_service) 80)
	(= (num_trains track_61_service) 0)

	; track: 62_service
	; ====================
	(= (entry_distance track_62_service) 2)
	(service_allowed track_62_service)
	(exit_allowed track_62_service)
	(= (max_num_trains track_62_service) 1)
	(= (track_length track_62_service) 80)
	(= (num_trains track_62_service) 0)

	; track: 63
	; ====================
	(= (entry_distance track_63) 3)
	(parking_allowed track_63)
	(exit_allowed track_63)
	(= (max_num_trains track_63) 100)
	(= (track_length track_63) 240)
	(= (num_trains track_63) 0)

	; track: entry
	; ====================
	(= (entry_distance track_entry) 0)
	(= (max_num_trains track_entry) 0)
	(= (track_length track_entry) 80)
	(= (num_trains track_entry) 11)


	; track connections
	; ====================
	(connected track_59 track_60)
	(connected track_54 track_60)
	(connected track_58 track_60)
	(connected track_53 track_60)
	(connected track_55 track_60)
	(connected track_52 track_60)
	(connected track_57 track_60)
	(connected track_56 track_60)
	(connected track_59 track_61_service)
	(connected track_56 track_61_service)
	(connected track_58 track_61_service)
	(connected track_57 track_61_service)
	(connected track_59 track_62_service)
	(connected track_56 track_62_service)
	(connected track_58 track_62_service)
	(connected track_57 track_62_service)
	(connected track_62_service track_63)
	(connected track_61_service track_63)
	(connected track_60 track_63)
	(connected track_entry track_52)
	(connected track_entry track_53)
	(connected track_entry track_54)
	(connected track_entry track_55)
	(connected track_entry track_56)
	(connected track_entry track_57)
	(connected track_entry track_58)
	(connected track_entry track_59)

	; train: slt40
	; ====================
	(available train_slt40)
	(= (train_length train_slt40) 80)

	(train_at train_slt40 track_entry)
	(= (order train_slt40) 11)

	; train: slt41
	; ====================
	(available train_slt41)
	(= (train_length train_slt41) 80)

	(train_at train_slt41 track_entry)
	(= (order train_slt41) 10)

	; train: slt42
	; ====================
	(available train_slt42)
	(= (train_length train_slt42) 80)

	(train_at train_slt42 track_entry)
	(= (order train_slt42) 9)

	; train: slt43
	; ====================
	(available train_slt43)
	(= (train_length train_slt43) 80)

	(train_at train_slt43 track_entry)
	(= (order train_slt43) 8)

	; train: slt44
	; ====================
	(available train_slt44)
	(= (train_length train_slt44) 80)

	(train_at train_slt44 track_entry)
	(= (order train_slt44) 7)

	; train: slt45
	; ====================
	(available train_slt45)
	(= (train_length train_slt45) 80)

	(train_at train_slt45 track_entry)
	(= (order train_slt45) 6)

	; train: slt46
	; ====================
	(available train_slt46)
	(= (train_length train_slt46) 80)

	(train_at train_slt46 track_entry)
	(= (order train_slt46) 5)

	; train: slt47
	; ====================
	(available train_slt47)
	(= (train_length train_slt47) 80)

	(train_at train_slt47 track_entry)
	(= (order train_slt47) 4)

	; train: slt48
	; ====================
	(available train_slt48)
	(= (train_length train_slt48) 80)

	(train_at train_slt48 track_entry)
	(= (order train_slt48) 3)

	; train: slt49
	; ====================
	(available train_slt49)
	(= (train_length train_slt49) 80)

	(train_at train_slt49 track_entry)
	(= (order train_slt49) 2)

	; train: slt50
	; ====================
	(available train_slt50)
	(= (train_length train_slt50) 80)

	(train_at train_slt50 track_entry)
	(= (order train_slt50) 1)


	(parking_pair train_slt40 train_slt41)
	(parking_pair train_slt40 train_slt42)
	(parking_pair train_slt40 train_slt43)
	(parking_pair train_slt40 train_slt44)
	(parking_pair train_slt40 train_slt45)
	(parking_pair train_slt40 train_slt46)
	(parking_pair train_slt40 train_slt47)
	(parking_pair train_slt40 train_slt48)
	(parking_pair train_slt40 train_slt49)
	(parking_pair train_slt40 train_slt50)
	(parking_pair train_slt41 train_slt42)
	(parking_pair train_slt41 train_slt43)
	(parking_pair train_slt41 train_slt44)
	(parking_pair train_slt41 train_slt45)
	(parking_pair train_slt41 train_slt46)
	(parking_pair train_slt41 train_slt47)
	(parking_pair train_slt41 train_slt48)
	(parking_pair train_slt41 train_slt49)
	(parking_pair train_slt41 train_slt50)
	(parking_pair train_slt42 train_slt43)
	(parking_pair train_slt42 train_slt44)
	(parking_pair train_slt42 train_slt45)
	(parking_pair train_slt42 train_slt46)
	(parking_pair train_slt42 train_slt47)
	(parking_pair train_slt42 train_slt48)
	(parking_pair train_slt42 train_slt49)
	(parking_pair train_slt42 train_slt50)
	(parking_pair train_slt43 train_slt44)
	(parking_pair train_slt43 train_slt45)
	(parking_pair train_slt43 train_slt46)
	(parking_pair train_slt43 train_slt47)
	(parking_pair train_slt43 train_slt48)
	(parking_pair train_slt43 train_slt49)
	(parking_pair train_slt43 train_slt50)
	(parking_pair train_slt44 train_slt45)
	(parking_pair train_slt44 train_slt46)
	(parking_pair train_slt44 train_slt47)
	(parking_pair train_slt44 train_slt48)
	(parking_pair train_slt44 train_slt49)
	(parking_pair train_slt44 train_slt50)
	(parking_pair train_slt45 train_slt46)
	(parking_pair train_slt45 train_slt47)
	(parking_pair train_slt45 train_slt48)
	(parking_pair train_slt45 train_slt49)
	(parking_pair train_slt45 train_slt50)
	(parking_pair train_slt46 train_slt47)
	(parking_pair train_slt46 train_slt48)
	(parking_pair train_slt46 train_slt49)
	(parking_pair train_slt46 train_slt50)
	(parking_pair train_slt47 train_slt48)
	(parking_pair train_slt47 train_slt49)
	(parking_pair train_slt47 train_slt50)
	(parking_pair train_slt48 train_slt49)
	(parking_pair train_slt48 train_slt50)
	(parking_pair train_slt49 train_slt50)
)
(:goal (and
	(ahead_aside train_slt40 train_slt41)
	(ahead_aside train_slt40 train_slt42)
	(ahead_aside train_slt40 train_slt43)
	(ahead_aside train_slt40 train_slt44)
	(ahead_aside train_slt40 train_slt45)
	(ahead_aside train_slt40 train_slt46)
	(ahead_aside train_slt40 train_slt47)
	(ahead_aside train_slt40 train_slt48)
	(ahead_aside train_slt40 train_slt49)
	(ahead_aside train_slt40 train_slt50)
	(ahead_aside train_slt41 train_slt42)
	(ahead_aside train_slt41 train_slt43)
	(ahead_aside train_slt41 train_slt44)
	(ahead_aside train_slt41 train_slt45)
	(ahead_aside train_slt41 train_slt46)
	(ahead_aside train_slt41 train_slt47)
	(ahead_aside train_slt41 train_slt48)
	(ahead_aside train_slt41 train_slt49)
	(ahead_aside train_slt41 train_slt50)
	(ahead_aside train_slt42 train_slt43)
	(ahead_aside train_slt42 train_slt44)
	(ahead_aside train_slt42 train_slt45)
	(ahead_aside train_slt42 train_slt46)
	(ahead_aside train_slt42 train_slt47)
	(ahead_aside train_slt42 train_slt48)
	(ahead_aside train_slt42 train_slt49)
	(ahead_aside train_slt42 train_slt50)
	(ahead_aside train_slt43 train_slt44)
	(ahead_aside train_slt43 train_slt45)
	(ahead_aside train_slt43 train_slt46)
	(ahead_aside train_slt43 train_slt47)
	(ahead_aside train_slt43 train_slt48)
	(ahead_aside train_slt43 train_slt49)
	(ahead_aside train_slt43 train_slt50)
	(ahead_aside train_slt44 train_slt45)
	(ahead_aside train_slt44 train_slt46)
	(ahead_aside train_slt44 train_slt47)
	(ahead_aside train_slt44 train_slt48)
	(ahead_aside train_slt44 train_slt49)
	(ahead_aside train_slt44 train_slt50)
	(ahead_aside train_slt45 train_slt46)
	(ahead_aside train_slt45 train_slt47)
	(ahead_aside train_slt45 train_slt48)
	(ahead_aside train_slt45 train_slt49)
	(ahead_aside train_slt45 train_slt50)
	(ahead_aside train_slt46 train_slt47)
	(ahead_aside train_slt46 train_slt48)
	(ahead_aside train_slt46 train_slt49)
	(ahead_aside train_slt46 train_slt50)
	(ahead_aside train_slt47 train_slt48)
	(ahead_aside train_slt47 train_slt49)
	(ahead_aside train_slt47 train_slt50)
	(ahead_aside train_slt48 train_slt49)
	(ahead_aside train_slt48 train_slt50)
	(ahead_aside train_slt49 train_slt50)
))
(:metric minimize (total-cost))
)