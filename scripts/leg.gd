class_name Leg extends Node3D

@export var femur_length: float = 0.37
@export var tibia_length: float = 0.57
@export var metatarsal_length: float = 0.21
@export var toe_length: float = 0.06
@export var ankle_rise: float = 1.5

enum LegType {LEG_FRONT, LEG_BACK}
@export var leg_type: LegType = LegType.LEG_BACK

@onready var foot_target: Node3D = $FootTarget
@onready var oscillator: Oscillator = $Oscillator

var femur: Node3D = null
var tibia: Node3D = null
var metatarsal: Node3D = null
var toe: Node3D = null

func _enter_tree():
	regenerate_segments()

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
	mesh.position.y = -(segment_length/2)
	
	return segment
