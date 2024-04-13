extends Button

@export var gait_speed: float = 1.0
@export var front_back_phase_offset: float = PI/4
@export var left_right_phase_offset: float = PI/2
@export var step_height: float = 0.25
@export var step_length: float = 0.25
@export var swing_stance_bias: float = 0

@export var control_panel: ControlPanel

func _ready():
	pressed.connect(_button_pressed)

func _button_pressed():
	control_panel.gait_speed_slider.value = gait_speed
	control_panel.front_back_phase_offset_slider.value = front_back_phase_offset
	control_panel.left_right_phase_offset_slider.value = left_right_phase_offset
	control_panel.step_height_slider.value = step_height
	control_panel.step_length_slider.value = step_length
	control_panel.swing_stance_bias_slider.value = swing_stance_bias
