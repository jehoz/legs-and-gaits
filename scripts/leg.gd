class_name Leg extends Node3D

const MIN_SEGMENT_LENGTH: float = 0.0001
const MIN_LEG_EXTENSION: float = 0.2

@export var femur_length: float = 0.5
@export var tibia_length: float = 0.45
@export var metatarsal_length: float = 0.3
@export var toe_length: float = 0.2
@export var ankle_lift: float = 0.8
@export var natural_bend: float = 0.15

@export var step_height: float = 0.125
@export var step_length: float = 0.25
@export var osc_vertical_bias: float = 1.0
@export var osc_horizontal_bias: float = 1.0

@export var leg_type: LegBlueprint.LegType = LegBlueprint.LegType.LEG_BACK

var foot_target: Node3D = null
var oscillator: Oscillator = null

var femur: Node3D = null
var tibia: Node3D = null
var metatarsal: Node3D = null
var toe: Node3D = null

var material: Material = null

func _init(blueprint: LegBlueprint, phase_offset: float, material: Material = null):
	# copy values from blueprint
	femur_length = blueprint.femur_length
	tibia_length = blueprint.tibia_length
	metatarsal_length = blueprint.metatarsal_length
	toe_length = blueprint.toe_length
	ankle_lift = blueprint.ankle_lift
	leg_type = blueprint.leg_type
	
	self.material = material
	
	if oscillator == null:
		oscillator = Oscillator.new(blueprint.speed, phase_offset)
		oscillator.name = "Oscillator"
		add_child(oscillator)
	if foot_target == null:
		foot_target = Node3D.new()
		foot_target.name = "FootTarget"
		add_child(foot_target)

func _enter_tree():
	regenerate_segments()

func _process(delta):
	update_segment_lengths()
	
	move_foot_target()
	solve_ik()
	move_toe(delta)

func regenerate_segments():
	if femur != null:
		femur.queue_free() # will also free rest of segments
	
	femur = make_segment(femur_length)
	add_child(femur)
	
	tibia = make_segment(tibia_length)
	femur.add_child(tibia)
	tibia.position.y = -femur_length
	
	metatarsal = make_segment(metatarsal_length)
	tibia.add_child(metatarsal)
	metatarsal.position.y = -tibia_length
	
	toe = make_segment(toe_length)
	metatarsal.add_child(toe)
	toe.position.y = -metatarsal_length

func make_segment(segment_length: float):
	var mesh = MeshInstance3D.new()
	mesh.mesh = CapsuleMesh.new()
	mesh.mesh.height = segment_length
	mesh.mesh.radius = 0.015
	mesh.material_override = self.material
	
	var segment = Node3D.new()
	segment.add_child(mesh)
	mesh.name = "Mesh"
	mesh.position.y = -(segment_length/2)
	
	return segment

func update_from_blueprint(blueprint: LegBlueprint, new_phase_offset: float):
	femur_length = blueprint.femur_length
	tibia_length = blueprint.tibia_length
	metatarsal_length = blueprint.metatarsal_length
	toe_length = blueprint.toe_length
	ankle_lift = blueprint.ankle_lift
	natural_bend = blueprint.natural_bend
	leg_type = blueprint.leg_type
	
	step_height = blueprint.step_height * max_length()
	step_length = blueprint.step_length * max_length()
	osc_vertical_bias = blueprint.osc_vertical_bias
	osc_horizontal_bias = blueprint.osc_horizontal_bias
	
	oscillator.frequency = blueprint.speed
	oscillator.phase = new_phase_offset

func update_segment_lengths():
	var helper = func update_segment(segment, segment_length, parent_length):
		var mesh = segment.get_node("Mesh")
		mesh.mesh.height = max(MIN_SEGMENT_LENGTH, segment_length)
		mesh.mesh.radius = 0.015
		mesh.position.y = -(segment_length/2)
		segment.position.y = -parent_length
	helper.call(femur, femur_length, 0)
	helper.call(tibia, tibia_length, femur_length)
	helper.call(metatarsal, metatarsal_length, tibia_length)
	helper.call(toe, toe_length, metatarsal_length)

func max_length():
	var a = metatarsal_length * sin(ankle_lift)
	var b = metatarsal_length * cos(ankle_lift)
	return sqrt(pow(femur_length + tibia_length, 2) - pow(b, 2)) + a

func resting_length():
	return max_length() * clampf(1 - natural_bend, MIN_LEG_EXTENSION, 1)

func min_length():
	return max_length() * MIN_LEG_EXTENSION

func move_foot_target():
	var forward = -global_basis.z
	var bottom = max(0, global_position.y - max_length())
	var step_max = resting_length()
	
	foot_target.position = Vector3.FORWARD * oscillator.bias_slope(osc_horizontal_bias) * step_length * step_max
	foot_target.global_position.y = bottom + max(0, oscillator.bias_peak(osc_vertical_bias, PI/2)) * step_height * step_max
	
	if foot_target.position.length() > max_length():
		foot_target.position = foot_target.position.normalized() * max_length()
	elif foot_target.position.length() < min_length():
		foot_target.position = foot_target.position.normalized() * min_length()

func is_planted():
	return oscillator.bias_peak(osc_vertical_bias, PI/2) <= 0

func solve_ik():
	var forward = -global_basis.z
	var left = global_basis.x
	
	var ball_pos = foot_target.global_position
	
	# ankle lift increases as leg extends beyond resting length, and vice versa
	var hip_to_ball = ball_pos - global_position
	var current_length = hip_to_ball.length()
	var _ankle_lift = ankle_lift * min(1, sqrt(current_length / resting_length()))
	if current_length > resting_length():
		_ankle_lift += (PI / 2 - ankle_lift) * pow((current_length - resting_length()) / (max_length() - resting_length()), 2)
	
	# ankle also rotates with the rest of the leg
	var leg_xz = Vector2(hip_to_ball.x, hip_to_ball.z)
	var fw_xz = Vector2(forward.x, forward.z)
	var xz_len = leg_xz.length() * sign(fw_xz.dot(leg_xz))
	_ankle_lift += atan(xz_len / hip_to_ball.y)
	
	# make sure heel doesn't clip through ground
	if ball_pos.y + metatarsal_length * sin(_ankle_lift) < 0:
		_ankle_lift = asin(-ball_pos.y / metatarsal_length)
	
	# ankle position is computed from ball position and heel elevation
	var a_off_xz = metatarsal_length * cos(_ankle_lift) * -forward
	var ankle_offset = Vector3(a_off_xz.x, metatarsal_length * sin(_ankle_lift), a_off_xz.z)
	var ankle_pos = ball_pos + ankle_offset
	
	# law of cosines to find hip joint angle
	var l = global_position.distance_to(ankle_pos)
	var gamma = 0
	if l < femur_length + tibia_length:
		var n = pow(l, 2) + pow(femur_length, 2) - pow(tibia_length, 2)
		var d = 2 * l * femur_length
		gamma = acos(n / d)
	
	if leg_type == LegBlueprint.LegType.LEG_FRONT:
		gamma *= -1
	
	var knee_offset = (ankle_pos - global_position).normalized() * femur_length
	var knee_pos = global_position + Quaternion(left, gamma) * knee_offset
	
	var prev = get_global_transform()
	var bones = [femur, tibia, metatarsal]
	var joints = [knee_pos, ankle_pos, ball_pos]
	for i in range(bones.size()):
		var bone: Node3D = bones[i]
		var joint_pos: Vector3 = joints[i]
		var from: Vector3 = -prev.basis.y
		var to: Vector3 = (joint_pos - prev.origin).normalized()
		var rot_quat = Quaternion(from, to)
		bone.rotation = Vector3.ZERO
		bone.global_rotate(rot_quat.get_axis().normalized(), rot_quat.get_angle())
		bone.scale = Vector3.ONE
		bone.global_position = prev.origin
		prev = bone.get_global_transform()
		prev.origin = joint_pos

func move_toe(delta: float):
	var current_angle = (-metatarsal.global_basis.y).angle_to(-toe.global_basis.y)
	
	var target_angle: float
	if is_planted():
		target_angle = (-metatarsal.global_basis.y).angle_to(-global_basis.z)
	else:
		target_angle = ankle_lift
	
	toe.rotate_x((target_angle - current_angle) * delta * 15)

