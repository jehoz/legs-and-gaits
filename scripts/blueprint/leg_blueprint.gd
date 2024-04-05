class_name LegBlueprint extends Resource

@export var femur_length: float = 0.5
@export var tibia_length: float = 0.45
@export var metatarsal_length: float = 0.3
@export var toe_length: float = 0.2
@export var ankle_lift: float = 0.8

enum LegType {LEG_FRONT, LEG_BACK}
@export var leg_type: LegType = LegType.LEG_BACK

# populated by parent blueprint
var speed: float = 1.0
var base_phase_offset: float = 0
var side_phase_difference: float = PI

var step_height: float = 0.125
var step_length: float = 0.25
var osc_vertical_bias = -1.0
var osc_horizontal_bias = 0.5
