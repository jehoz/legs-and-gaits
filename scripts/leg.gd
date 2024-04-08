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

func _init(blueprint: LegBlueprint, phase_offset: float):
	# copy values from blueprint
	femur_length = blueprint.femur_length
	tibia_length = blueprint.tibia_length
	metatarsal_length = blueprint.metatarsal_length
	toe_length = blueprint.toe_length
	ankle_lift = blueprint.ankle_lift
	leg_type = blueprint.leg_type
	
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
	
	#foot_target.global_position = global_position + (forward * (oscillator.skewed(osc_horizontal_bias) * step_length))
	foot_target.position = Vector3.FORWARD * oscillator.bias_slope(osc_horizontal_bias) * step_length
	foot_target.global_position.y = bottom + max(0, oscillator.bias_peak(osc_vertical_bias, PI/2)) * step_height
	#foot_target.position.y = -resting_length() + max(0, oscillator.asymmetric(osc_vertical_bias, PI/2)) * step_height
	
	if foot_target.position.length() > max_length():
		foot_target.position = foot_target.position.normalized() * max_length()
	elif foot_target.position.length() < min_length():
		foot_target.position = foot_target.position.normalized() * max_length()

func is_planted():
	return oscillator.bias_peak(osc_vertical_bias, PI/2) <= 0

func is_load_phase():
	return is_planted() and foot_target.position.z > 0

func solve_ik():
	var forward = -global_basis.z
	var left = global_basis.x
	
	# position of joint between toe and metatarsal is offset from foot target
	# depending on how high the heel is raised
	# for fully plantigrade feet the target is the heel of the foot, for fully
	# ungiligrade feet the target is the ball of the foot
	var ball_offset = (cos(ankle_lift) * metatarsal_length) * forward
	var ball_pos = foot_target.global_position + ball_offset
	
	# foot rotates slightly as the leg moves forward and backward, modifying the
	# final angle of heel elevation and the toe bone
	var hip_to_ball = ball_pos - global_position # hip is leg's origin
	var leg_xz = Vector2(hip_to_ball.x, hip_to_ball.z)
	var fw_xz = Vector2(forward.x, forward.z)
	var xz_len = leg_xz.length() * sign(fw_xz.dot(leg_xz))
	var delta_angle = atan(xz_len / hip_to_ball.y)
	var _ankle_lift = ankle_lift + delta_angle
	if ball_pos.y + metatarsal_length * sin(_ankle_lift) < 0:
		_ankle_lift = asin(-ball_pos.y / metatarsal_length)
		delta_angle = _ankle_lift - ankle_lift
	var toe_pos = ball_pos + (Quaternion(left, -min(0, delta_angle)) * forward * toe_length)
	
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
	var bones = [femur, tibia, metatarsal, toe]
	var joints = [knee_pos, ankle_pos, ball_pos, toe_pos]
	for i in range(4):
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
