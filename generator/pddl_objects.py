
from typing import List

from generator.option_enums import LengthOption, LocationOption, MovementOption, Goal, ConcurrencyOption

class Train:

    def __init__(self, name: str, length: int, priority = None, available=True):
        self.name = name
        self.length = length
        self.available = available
        self.priority = priority
        self.goals: List[Goal] = []

    def __str__(self) -> str:
        return f"name: {self.name} --- length: {self.length}--- available: {self.available}" 
    
    def __repr__(self) -> str:
        return self.name
    
    def object_name(self, length_option: LengthOption) -> str:
        if length_option == LengthOption.NUMERIC:
            return f"\ttrain_{self.name} - train"

    def init_fluents(self, 
                length_option: LengthOption, 
                location_option: LocationOption,
                concurrency_option: ConcurrencyOption,
                distance: int = None,
                order=0,
                resolution=None) -> str:
        lines = [f"\t; train: {self.name}",
                 "\t; ====================", 
                 ]
        if concurrency_option == ConcurrencyOption.DRIVER_OBJECTS:
            lines.append(f"\t(unoperated train_{self.name})")

        if self.available:
            lines.append(f"\t(available train_{self.name})")
            
        if self.priority is not None:
            lines.append(f"\t(= (priority train_{self.name}) {self.priority})")
            
        lines.append(f"\t(= (train_entry_distance train_{self.name}) 0)")

        if length_option == LengthOption.NUMERIC:
            lines.append(f"\t(= (train_length train_{self.name}) {self.length})")
        
        lines.append("")
            
        lines.append(f"\t(train_at train_{self.name} track_entry)")
        if location_option == LocationOption.RELATIVE:
            if order <= 0:
                raise Exception("Must provide order if train location on track is relative")
            lines.append(f"\t(= (order train_{self.name}) {order})")

        if distance is not None:
            lines.append(f"\t(= (aside_distance train_{self.name}) {distance})")

        lines.append("")

        return lines

    
    
class Track:

    def __init__(self, name: str, length: int, parking: bool = True, service: bool = False, is_entry: bool = False):
        self.name = name
        self.length = length
        self.parking = parking
        self.service = service
        self.is_entry = is_entry
        self.entry_distance = 0
        self.num_trains = 0

    def __str__(self) -> str:
        return f"name: {self.name} --- length: {self.length} --- parking: {self.parking} --- service: {self.service}" 
    
    def object_name(self, length_option: LengthOption) -> str:
        if length_option == LengthOption.NUMERIC:
            return f"\ttrack_{self.name} - track"

    def init_fluents(self, 
                length_option: LengthOption, 
                location_option: LocationOption,
                movement_option: MovementOption,
                entry_distance,
                max_length=-1,
                resolution=None) -> str:
        lines = [f"\t; track: {self.name}", "\t; ===================="]
        lines.append(f"\t(= (track_entry_distance track_{self.name}) {entry_distance})")

        if not self.is_entry:
            lines.append(f"\t(in_yard track_{self.name})")

        if self.parking:
            lines.append(f"\t(parking_allowed track_{self.name})")

        if self.service:
            lines.append(f"\t(service_allowed track_{self.name})")
            lines.append(f"\t(= (track_length track_{self.name}) {max_length})")
        elif length_option == LengthOption.NUMERIC:
            lines.append(f"\t(= (track_length track_{self.name}) {self.length})")
        
        # if location_option == LocationOption.RELATIVE:
        lines.append(f"\t(= (num_trains track_{self.name}) {self.num_trains})")

        if movement_option == MovementOption.END_OF_TRACK:
            lines.append(f"\t(= (astack_distance track_{self.name}) 0)")
            if self.is_entry:
                lines.append(f"\t(= (bstack_distance track_{self.name}) {self.length})")
            else:
                lines.append(f"\t(= (bstack_distance track_{self.name}) 0)")

        lines.append("")

        return lines

    def __repr__(self) -> str:
        return self.name
    

class Driver:

    def __init__(self, name):
        self.name = name

    def __str__(self) -> str:
        return f"name: {self.name}"
    
    def __repr__(self) -> str:
        return self.name
    
    def object_name(self) -> str:
        return f"\tdriver_{self.name} - driver"
    
    def init_fluents(self, walking_included=False):
        lines = [f"\t; driver: {self.name}", 
                 "\t; ====================",
                 f"\t(idle driver_{self.name})"]
        
        if walking_included:
            lines.append(f"\t(driver_at driver_{self.name} track_entry)")

        lines.append("")

        return lines
