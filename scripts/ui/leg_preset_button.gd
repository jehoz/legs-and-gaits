extends Button

@export var front_femur_length: float = 0.449
@export var front_tibia_length: float = 0.45
@export var front_metatarsal_length: float = 0.099
@export var front_toe_length: float = 0.079
@export var front_ankle_lift: float = 0.206
@export var front_natural_bend: float = 0.131

@export var rear_femur_length: float = 0.476
@export var rear_tibia_length: float = 0.498
@export var rear_metatarsal_length: float = 0.132
@export var rear_toe_length: float = 0.088
@export var rear_ankle_lift: float = 0.24
@export var rear_natural_bend: float = 0.082

@export var control_panel: ControlPanel

func _ready():
	pressed.connect(_button_pressed)

func _button_pressed():
	control_panel.front_femur_slider.value = front_femur_length
	control_panel.front_tibia_slider.value = front_tibia_length
	control_panel.front_metatarsal_slider.value = front_metatarsal_length
	control_panel.front_toe_slider.value = front_toe_length
	control_panel.front_ankle_lift_slider.value = front_ankle_lift
	control_panel.front_natural_bend_slider.value = front_natural_bend

	control_panel.rear_femur_slider.value = rear_femur_length
	control_panel.rear_tibia_slider.value = rear_tibia_length
	control_panel.rear_metatarsal_slider.value = rear_metatarsal_length
	control_panel.rear_toe_slider.value = rear_toe_length
	control_panel.rear_ankle_lift_slider.value = rear_ankle_lift
	control_panel.rear_natural_bend_slider.value = rear_natural_bend
