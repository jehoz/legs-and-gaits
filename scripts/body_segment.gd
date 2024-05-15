class_name BodySegment extends Node3D

@export var radius: float = 0.2
@export var length: float = 0.2

var leg_l: Leg = null
var leg_r: Leg = null

var resting_height: float = 0
var z_offset: float = 0
var material: Material = null

func _init(radius: float, length: float, z_offset: float, material: Material = null):
	self.radius = radius
	self.length = length
	self.z_offset = z_offset
	self.material = material

func set_legs(leg_blueprint: LegBlueprint, phase_offset: float):
	if leg_l == null:  # assume that if one leg is exists, both exist
		leg_l = Leg.new(leg_blueprint, phase_offset, material)
		leg_l.name = "Leg L"
		add_child(leg_l)
		
		leg_r = Leg.new(leg_blueprint, phase_offset + leg_blueprint.side_phase_difference, material)
		leg_r.name = "Leg R"
		add_child(leg_r)
		
	else:
		leg_l.update_from_blueprint(leg_blueprint, phase_offset)
		leg_r.update_from_blueprint(leg_blueprint, phase_offset + leg_blueprint.side_phase_difference)

	resting_height = leg_l.resting_length()
	leg_l.position.x = -radius
	leg_r.position.x = radius

func _ready():
	var mesh = MeshInstance3D.new()
	mesh.mesh = CapsuleMesh.new()
	mesh.mesh.radius = radius
	mesh.mesh.height = length + (2 * radius)
	mesh.material_overlay = self.material
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
	
	var twist = atan2(foot_diff.y * 0.5, foot_diff.x)
	
	var look_target = global_position + (-get_parent_node_3d().global_basis.z)
	look_at(look_target, global_basis.y)
	rotate_y(-twist * 0.1)
	
	# bob up and down
	var bounce_amt = 0.1 - 0.01 * leg_l.osc_vertical_bias
	var bounce_off = 0.15
	var avg_leg_osc = (
		leg_l.oscillator.bias_slope(leg_l.osc_vertical_bias / 2, bounce_off) +
		leg_r.oscillator.bias_slope(leg_r.osc_vertical_bias / 2, bounce_off)
		) / 2
	var y = leg_l.resting_length() - bounce_amt * avg_leg_osc
	global_position.y = y
