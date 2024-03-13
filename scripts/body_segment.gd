class_name BodySegment extends Node3D

@export var radius: float = 0.2

var leg_l: Leg = null
var leg_r: Leg = null

var resting_height: float = 0
var z_offset: float = 0
var y_velocity: float = 0

func _init(blueprint: BodySegmentBlueprint):
	radius = blueprint.radius
	z_offset = blueprint._z_offset
	
	if blueprint.leg_blueprint != null:
		blueprint.leg_blueprint._speed = blueprint._speed
		blueprint.leg_blueprint._phase_offset = blueprint._phase_offset
		
		leg_l = Leg.new(blueprint.leg_blueprint)
		leg_l.name = "Leg L"
		add_child(leg_l)
		
		leg_r = Leg.new(blueprint.leg_blueprint, PI)
		leg_r.name = "Leg R"
		add_child(leg_r)

func _ready():
	if leg_l != null:
		resting_height = leg_l.max_length() * 0.85
		leg_l.position.x = -radius
	
	if leg_r != null:
		leg_r.position.x = radius
	
	var mesh = MeshInstance3D.new()
	mesh.mesh = SphereMesh.new()
	mesh.mesh.radius = radius
	mesh.mesh.height = 2 * radius
	add_child(mesh)
	
	position.y = resting_height

func _process(delta):
	if leg_l == null:
		position.z = z_offset
		return
	
	var y_target = resting_height - 0.05
	if leg_l.is_load_phase() or leg_r.is_load_phase():
		y_target = resting_height + 0.05
	
	var error = y_target - position.y
	y_velocity = 1.55 * error - 0.75 * (error - y_velocity)
	
	position.z = z_offset
	position.y += y_velocity * delta
