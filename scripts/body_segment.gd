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
	if leg_l == null:
		position.z = z_offset
		return
	
	if (leg_l.is_planted() or leg_r.is_planted()) and position.y < resting_height:
		var force = (atan(10 + leg_l.osc_vertical_bias) + PI) / (2 * PI)
		force *= max(-leg_l.oscillator.asymmetric(leg_l.osc_vertical_bias),
					 -leg_r.oscillator.asymmetric(leg_r.osc_vertical_bias))
		
		var error = resting_height - position.y
		
		y_velocity += (500.0 * error) * delta * force
		y_velocity /= 2.0
		prev_error = error
	
	y_velocity -= GRAVITY * delta
	
	position.z = z_offset
	position.y += y_velocity * delta
	
	# don't fall through the ground
	if position.y < radius:
		position.y = radius
		y_velocity = 0
