class_name BodySegment extends Node3D

@export var radius: float = 0.2

var oscillator: Oscillator = null
var leg_l: Leg = null
var leg_r: Leg = null

var resting_height: float = 0

func _init(blueprint: BodySegmentBlueprint):
	radius = blueprint.radius
	if blueprint.leg_blueprint != null:
		blueprint.leg_blueprint._speed = blueprint._speed
		blueprint.leg_blueprint._phase_offset = blueprint._phase_offset
		
		leg_l = Leg.new(blueprint.leg_blueprint)
		leg_l.name = "Leg L"
		add_child(leg_l)
		
		leg_r = Leg.new(blueprint.leg_blueprint, PI)
		leg_l.name = "Leg R"
		add_child(leg_r)
		
		oscillator = Oscillator.new(2 * blueprint._speed, blueprint._phase_offset + 0.93)
		oscillator.name = "Oscillator"
		add_child(oscillator)

func _ready():
	if leg_l != null:
		resting_height = leg_l.max_length() * 0.9
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
	position.y = resting_height - 0.025 * oscillator.asymmetric(1.0)
