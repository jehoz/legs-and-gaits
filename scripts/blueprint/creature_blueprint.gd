class_name CreatureBlueprint extends Resource

@export_group("Body")
@export var body_length: float = 1.0
@export var body_shape: Curve 
@export var num_body_segments: int = 5

@export_group("Legs")
@export var front_leg_blueprint: LegBlueprint
@export var rear_leg_blueprint: LegBlueprint

@export_group("Gait")
@export var speed: float = 3.5

## Difference in oscillator phases between front and back legs
@export var leg_pair_phase_difference = PI/2

## Difference in oscillator phases between left and right leg of same pair
@export var leg_side_phase_difference = PI

@export var step_height = 0.125
@export var step_length = 0.25
@export var osc_vertical_bias = -1.0
@export var osc_horizontal_bias = 0.5

## propagates gait values to leg blueprints
func update_legs():
	for leg_bp in [front_leg_blueprint, rear_leg_blueprint]:
		if leg_bp == null:
			continue
		
		leg_bp.speed = speed
		leg_bp.step_height = step_height
		leg_bp.step_length = step_length
		leg_bp.osc_vertical_bias = osc_vertical_bias
		leg_bp.osc_horizontal_bias = osc_horizontal_bias
		
		leg_bp.side_phase_difference = leg_side_phase_difference
	
	if front_leg_blueprint != null:
		front_leg_blueprint.base_phase_offset = 0
	if rear_leg_blueprint != null:
		rear_leg_blueprint.base_phase_offset = leg_pair_phase_difference
