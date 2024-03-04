class_name BodySegment extends Node3D

@export var radius: float = 0.2

var leg_l: Leg = null
var leg_r: Leg = null

var resting_height: float = 0

func _init(blueprint: BodySegmentBlueprint):
	radius = blueprint.radius
	if blueprint.leg_blueprint != null:
		leg_l = Leg.new(blueprint.leg_blueprint, blueprint.leg_phase_offset)
		leg_l.name = "Leg L"
		add_child(leg_l)
		leg_r = Leg.new(blueprint.leg_blueprint, blueprint.leg_phase_offset+PI)
		leg_l.name = "Leg R"
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
