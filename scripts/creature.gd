class_name Creature extends Node3D

@export var blueprint: CreatureBlueprint = null

var body_segments: Array[BodySegment] = []

func _enter_tree():
	if blueprint == null:
		return
	
	blueprint.connect("changed", propagate_blueprint_changes)
	
	var i = 0
	for segment_blueprint in blueprint.body_segments:
		segment_blueprint._speed = blueprint.speed
		segment_blueprint._phase_offset = i * blueprint.leg_pair_phase_difference
		var bs = BodySegment.new(segment_blueprint)
		bs.name = "BodySegment" + str(i)
		add_child(bs)
		body_segments.append(bs)
		i += 1

func propagate_blueprint_changes():
	if blueprint == null:
		return
	
