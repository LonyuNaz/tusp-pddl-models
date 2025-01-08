
from enum import Enum

class CostOption(Enum):
    DURATION = 1
    METRIC = 2

class LengthOption(Enum):
    NUMERIC = 1
    DISCRETE = 2

class LocationOption(Enum):
    RELATIVE = 1
    EXACT = 2

class MovementOption(Enum):
    ACROSS = 1
    END_OF_TRACK = 2

class TurnOption(Enum):
    NONE = 1
    DEFAULT_ASIDE = 2
    DEFAULT_BSIDE = 3

class CrewOption(Enum):
    DRIVER_OBJECTS = 1
    NONE = 2

class Goal(Enum):
    PARKED = 1
    SERVICED = 2
    SERVICED_AND_PARKED = 3
    AHEAD = 4
    AT_ENTRY = 5
    ORDER = 6
    AHEAD_ALL = 7
    SERVICED_ALL = 8

class GoalOption(Enum):
    ACTION_TYPE = 1
    ACTION_TRAIN = 2
    DERIVED_TRAIN = 3

class Direction(Enum):
    ASIDE = 1
    BSIDE = 2

class ParkOption(Enum):
    DERIVED_PREDICATES = 1
    ACTION = 2

class SwitchOption(Enum):
    NONE = 1
    ACTIONS = 2