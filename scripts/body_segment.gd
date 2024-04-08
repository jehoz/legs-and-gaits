class_name BodySegment extends Node3D

@export var radius: float = 0.2
@export var length: float = 0.2

const GRAVITY: float = 2.5

var leg_l: Leg = null
var leg_r: Leg = null

var resting_height: float = 0
var z_offset: float = 0
var y_velocity: float = 0

func _init(radius: float, length: float, z_offset: float):
	self.radius = radius
	self.length = length
	self.z_offset = z_offset

func set_legs(leg_blueprint: LegBlueprint, phase_offset: float):
	if leg_l == null:  # assume that if one leg is exists, both exist
		leg_l = Leg.new(leg_blueprint, phase_offset)
		leg_l.name = "Leg L"
		add_child(leg_l)
		
		leg_r = Leg.new(leg_blueprint, phase_offset + leg_blueprint.side_phase_difference)
		leg_r.name = "Leg R"
		add_child(leg_r)
		
	else:
		leg_l.update_from_blueprint(leg_blueprint, phase_offset)
		leg_r.update_from_blueprint(leg_blueprint, phase_offset + leg_blueprint.side_phase_difference)

	resting_height = leg_l.max_length() * (1 - clampf(leg_blueprint.natural_bend, 0, 1))
	leg_l.position.x = -radius
	leg_r.position.x = radius

func _ready():
	var mesh = MeshInstance3D.new()
	mesh.mesh = CapsuleMesh.new()
	mesh.mesh.radius = radius
	mesh.mesh.height = length + (2 * radius)
	add_child(mesh)
	mesh.rotate(Vector3.LEFT, PI/2)
	
	position.y = resting_height

var prev_error = 0
func _process(delta):
	position.z = z_offset
	if leg_l == null:
		return
	
	# twist body segments with leg movement
	var foot_diff = leg_l.foot_target.global_position - leg_r.foot_target.global_position
	foot_diff = Vector2(foot_diff.x, foot_diff.z).normalized()
	var twist = atan2(foot_diff.y, foot_diff.x)
	var look_target = global_position + (-get_parent_node_3d().global_basis.z)
	look_at(look_target, global_basis.y)
	rotate_y(-twist * 0.1)
	
	# upward force applied by leg proportional to step
	var leg_force = max(-leg_l.oscillator.bias_peak(leg_l.osc_vertical_bias, PI/2),
					 	-leg_r.oscillator.bias_peak(leg_r.osc_vertical_bias, PI/2))
	# this just makes the walk animaton more natural looking
	var target_height = resting_height + leg_force * leg_l.max_length() * 0.1
	
	# apply upward acceleration to body segment when leg is planted
	if (leg_l.is_planted() or leg_r.is_planted()) and position.y < target_height:
		var error = target_height - position.y
		
		var p_coeff = 75 + pow(2, leg_l.osc_vertical_bias) * leg_force * 0.5
		var d_coeff = 10.0
		
		y_velocity += (p_coeff * error - d_coeff * (error - prev_error)) * delta
		y_velocity /= 2.0
		prev_error = error
	
	y_velocity -= GRAVITY * delta
	
	position.y += y_velocity * delta
	
	# don't fall through the ground
	var bottom = max(radius, leg_l.min_length())
	if position.y < bottom:
		position.y = bottom
		y_velocity = 0
