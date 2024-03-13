class_name LegBlueprint extends Resource

@export var femur_length: float = 0.5
@export var tibia_length: float = 0.45
@export var metatarsal_length: float = 0.3
@export var toe_length: float = 0.2
@export var heel_elevation: float = 0.8

enum LegType {LEG_FRONT, LEG_BACK}
@export var leg_type: LegType = LegType.LEG_BACK

# populated by parent blueprint
var _speed: float = 1.0
var _phase_offset: float = 0

var _step_height: float = 0.25
var _step_distance: float = 0.25
