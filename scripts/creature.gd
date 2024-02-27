class_name Creature extends Node3D

@export var leg_phase_offset: float = PI

var body_segments: Array[BodySegment] = []

func _init():
	# for now just create one body segment with legs
	var bs = BodySegment.new()
	var leg_l = Leg.new()
	var leg_r = Leg.new()
	bs.add_child(leg_l)
	bs.add_child(leg_r)
	leg_l.name = "Leg L"
	leg_r.name = "Leg R"
	add_child(bs)
