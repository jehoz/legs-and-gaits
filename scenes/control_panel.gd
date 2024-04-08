extends Control

@export_group("Internal")
@export var creature: Creature

@export var front_femur_slider: Slider
@export var front_tibia_slider: Slider
@export var front_metatarsal_slider: Slider
@export var front_toe_slider: Slider
@export var front_ankle_lift_slider: Slider
@export var front_natural_bend_slider: Slider

@export var rear_femur_slider: Slider
@export var rear_tibia_slider: Slider
@export var rear_metatarsal_slider: Slider
@export var rear_toe_slider: Slider
@export var rear_ankle_lift_slider: Slider
@export var rear_natural_bend_slider: Slider

const MIN_SEGMENT_LENGTH: float = 0.001
const MAX_SEGMENT_LENGTH: float = 1.0

const MIN_NATURAL_BEND: float = 0.0
const MAX_NATURAL_BEND: float = 0.75

@export var gait_speed_slider: Slider

const MIN_GAIT_SPEED: float = 0
const MAX_GAIT_SPEED: float = 20

@export var front_back_phase_offset_slider: Slider
@export var left_right_phase_offset_slider: Slider

const MIN_PHASE_OFFSET: float = 0
const MAX_PHASE_OFFSET: float = PI

@export var step_height_slider: Slider
@export var step_length_slider: Slider

const MIN_STEP_SIZE: float = 0
const MAX_STEP_SIZE: float = 1

@export var up_down_bias_slider: Slider

const MIN_VERTICAL_BIAS: float = -10
const MAX_VERTICAL_BIAS: float = 10

@export var front_back_bias_slider: Slider

const MIN_HORIZONTAL_BIAS: float = -1
const MAX_HORIZONTAL_BIAS: float = 1

func _ready():
	var bp: CreatureBlueprint = creature.blueprint
	var front_leg: LegBlueprint = bp.front_leg_blueprint
	var rear_leg: LegBlueprint = bp.rear_leg_blueprint
	
	for slider in [
			front_femur_slider, front_tibia_slider,
			front_metatarsal_slider, front_toe_slider,
			rear_femur_slider, rear_tibia_slider,
			rear_metatarsal_slider, rear_toe_slider
			]:
		slider.step = 0.001
		slider.max_value = MAX_SEGMENT_LENGTH
		slider.min_value = MIN_SEGMENT_LENGTH
	
	front_femur_slider.value = front_leg.femur_length
	front_tibia_slider.value = front_leg.tibia_length
	front_metatarsal_slider.value = front_leg.metatarsal_length
	front_toe_slider.value = front_leg.toe_length
	
	rear_femur_slider.value = rear_leg.femur_length
	rear_tibia_slider.value = rear_leg.tibia_length
	rear_metatarsal_slider.value = rear_leg.metatarsal_length
	rear_toe_slider.value = rear_leg.toe_length
	
	front_ankle_lift_slider.step = 0.001
	front_ankle_lift_slider.max_value = PI/2
	front_ankle_lift_slider.min_value = 0
	front_ankle_lift_slider.value = front_leg.ankle_lift
	
	rear_ankle_lift_slider.step = 0.001
	rear_ankle_lift_slider.max_value = PI/2
	rear_ankle_lift_slider.min_value = 0
	rear_ankle_lift_slider.value = rear_leg.ankle_lift
	
	front_natural_bend_slider.step = 0.001
	front_natural_bend_slider.max_value = MAX_NATURAL_BEND
	front_natural_bend_slider.min_value = MIN_NATURAL_BEND
	front_natural_bend_slider.value = front_leg.natural_bend
	
	rear_natural_bend_slider.step = 0.001
	rear_natural_bend_slider.max_value = MAX_NATURAL_BEND
	rear_natural_bend_slider.min_value = MIN_NATURAL_BEND
	rear_natural_bend_slider.value = rear_leg.natural_bend
	
	gait_speed_slider.step = 0.001
	gait_speed_slider.max_value = MAX_GAIT_SPEED
	gait_speed_slider.min_value = MIN_GAIT_SPEED
	gait_speed_slider.value = bp.speed
	
	front_back_phase_offset_slider.step = 0.001
	front_back_phase_offset_slider.max_value = MAX_PHASE_OFFSET
	front_back_phase_offset_slider.min_value = MIN_PHASE_OFFSET
	front_back_phase_offset_slider.value = bp.leg_pair_phase_difference
	
	left_right_phase_offset_slider.step = 0.001
	left_right_phase_offset_slider.max_value = MAX_PHASE_OFFSET
	left_right_phase_offset_slider.min_value = MIN_PHASE_OFFSET
	left_right_phase_offset_slider.value = bp.leg_side_phase_difference
	
	step_height_slider.step = 0.001
	step_height_slider.max_value = MAX_STEP_SIZE
	step_height_slider.min_value = MIN_STEP_SIZE
	step_height_slider.value = bp.step_height
	
	step_length_slider.step = 0.001
	step_length_slider.max_value = MAX_STEP_SIZE
	step_length_slider.min_value = MIN_STEP_SIZE
	step_length_slider.value = bp.step_length
	
	up_down_bias_slider.step = 0.001
	up_down_bias_slider.max_value = MAX_VERTICAL_BIAS
	up_down_bias_slider.min_value = MIN_VERTICAL_BIAS
	up_down_bias_slider.value = bp.osc_vertical_bias
	
	front_back_bias_slider.step = 0.001
	front_back_bias_slider.max_value = MAX_HORIZONTAL_BIAS
	front_back_bias_slider.min_value = MIN_HORIZONTAL_BIAS
	front_back_bias_slider.value = bp.osc_horizontal_bias
	
	for slider in [
			front_femur_slider, front_tibia_slider, 
			front_metatarsal_slider, front_toe_slider, 
			front_ankle_lift_slider, rear_femur_slider, 
			rear_tibia_slider, rear_metatarsal_slider, 
			rear_toe_slider, rear_ankle_lift_slider,
			front_natural_bend_slider, rear_natural_bend_slider,
			gait_speed_slider, front_back_phase_offset_slider, 
			left_right_phase_offset_slider,
			step_height_slider, step_length_slider,
			up_down_bias_slider, front_back_bias_slider]:
		slider.value_changed.connect(update_blueprint)

func update_blueprint(value):
	var front_leg: LegBlueprint = creature.blueprint.front_leg_blueprint
	var rear_leg: LegBlueprint = creature.blueprint.rear_leg_blueprint
	
	front_leg.femur_length = front_femur_slider.value
	front_leg.tibia_length = front_tibia_slider.value
	front_leg.metatarsal_length = front_metatarsal_slider.value
	front_leg.toe_length = front_toe_slider.value
	front_leg.ankle_lift = front_ankle_lift_slider.value
	front_leg.natural_bend = front_natural_bend_slider.value
	
	rear_leg.femur_length = rear_femur_slider.value
	rear_leg.tibia_length = rear_tibia_slider.value
	rear_leg.metatarsal_length = rear_metatarsal_slider.value
	rear_leg.toe_length = rear_toe_slider.value
	rear_leg.ankle_lift = rear_ankle_lift_slider.value
	rear_leg.natural_bend = rear_natural_bend_slider.value
	
	creature.blueprint.speed = gait_speed_slider.value
	creature.blueprint.step_height = step_height_slider.value
	creature.blueprint.step_length = step_length_slider.value
	creature.blueprint.osc_vertical_bias = up_down_bias_slider.value
	creature.blueprint.osc_horizontal_bias = front_back_bias_slider.value
	
	creature.blueprint.leg_pair_phase_difference = front_back_phase_offset_slider.value
	creature.blueprint.leg_side_phase_difference = left_right_phase_offset_slider.value
	
	creature.blueprint.front_leg_blueprint = front_leg
	creature.blueprint.rear_leg_blueprint = rear_leg
	
	creature.apply_blueprint_changes()
