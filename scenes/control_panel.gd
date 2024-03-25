extends Control

@export_group("Internal")
@export var creature: Creature

@export var front_femur_slider: Slider
@export var front_tibia_slider: Slider
@export var front_metatarsal_slider: Slider
@export var front_toe_slider: Slider
@export var front_ankle_lift_slider: Slider

@export var rear_femur_slider: Slider
@export var rear_tibia_slider: Slider
@export var rear_metatarsal_slider: Slider
@export var rear_toe_slider: Slider
@export var rear_ankle_lift_slider: Slider

const MIN_SEGMENT_LENGTH: float = 0.001
const MAX_SEGMENT_LENGTH: float = 1.0

func _ready():
	var bp: CreatureBlueprint = creature.blueprint
	var front_leg: LegBlueprint = bp.body_segments[0].leg_blueprint
	var rear_leg: LegBlueprint = bp.body_segments[-1].leg_blueprint
	
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
	
	for slider in [
			front_femur_slider, front_tibia_slider, 
			front_metatarsal_slider, front_toe_slider, 
			front_ankle_lift_slider, rear_femur_slider, 
			rear_tibia_slider, rear_metatarsal_slider, 
			rear_toe_slider, rear_ankle_lift_slider]:
		slider.value_changed.connect(update_blueprint)

func update_blueprint(value):
	var front_leg: LegBlueprint = creature.blueprint.body_segments[0].leg_blueprint
	var rear_leg: LegBlueprint = creature.blueprint.body_segments[-1].leg_blueprint
	front_leg.femur_length = front_femur_slider.value
	front_leg.tibia_length = front_tibia_slider.value
	front_leg.metatarsal_length = front_metatarsal_slider.value
	front_leg.toe_length = front_toe_slider.value
	front_leg.ankle_lift = front_ankle_lift_slider.value
	
	rear_leg.femur_length = rear_femur_slider.value
	rear_leg.tibia_length = rear_tibia_slider.value
	rear_leg.metatarsal_length = rear_metatarsal_slider.value
	rear_leg.toe_length = rear_toe_slider.value
	rear_leg.ankle_lift = rear_ankle_lift_slider.value
	
	creature.blueprint.body_segments[0].leg_blueprint = front_leg
	creature.blueprint.body_segments[-1].leg_blueprint = rear_leg
	
	creature.propagate_blueprint_changes()
