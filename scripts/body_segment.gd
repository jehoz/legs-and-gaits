class_name BodySegment extends Node3D

@export var radius: float = 0.2

@onready var leg_l: Leg = $"Leg L"
@onready var leg_r: Leg = $"Leg R"

var resting_height: float = 0

func _ready():
	if leg_l != null:
		resting_height = leg_l.max_length() * 0.75
		leg_l.position.x = -radius
	
	if leg_r != null:
		leg_r.position.x = radius
	
	var mesh = MeshInstance3D.new()
	mesh.mesh = SphereMesh.new()
	mesh.mesh.radius = radius
	mesh.mesh.height = 2 * radius
	add_child(mesh)
	
	position.y = resting_height
