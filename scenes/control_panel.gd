extends Control

@export_group("Internal")
@export var creature: Creature

@export var front_femur_slider: Slider
@export var front_tibia_slider: Slider
@export var front_metatarsal_slider: Slider
@export var front_toe_slider: Slider
@export var front_ankle_lift_slider: Slider

const MIN_SEGMENT_LENGTH: float = 0.001
const MAX_SEGMENT_LENGTH: float = 1.0

func _ready():
	var bp: CreatureBlueprint = creature.blueprint
	var front_leg: LegBlueprint = bp.body_segments[0].leg_blueprint
	
	for slider in [front_femur_slider, front_tibia_slider, front_metatarsal_slider, front_toe_slider]:
		slider.step = 0.001
		slider.max_value = MAX_SEGMENT_LENGTH
		slider.min_value = MIN_SEGMENT_LENGTH
	
	front_femur_slider.value = front_leg.femur_length
	front_tibia_slider.value = front_leg.tibia_length
	front_metatarsal_slider.value = front_leg.metatarsal_length
	front_toe_slider.value = front_leg.toe_length
	
	front_ankle_lift_slider.step = 0.001
	front_ankle_lift_slider.max_value = PI/2
	front_ankle_lift_slider.min_value = 0
	front_ankle_lift_slider.value = front_leg.ankle_lift
	

