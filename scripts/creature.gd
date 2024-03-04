class_name Creature extends Node3D

@export var blueprint: CreatureBlueprint = null

var body_segments: Array[BodySegment] = []

func _enter_tree():
	if blueprint != null:
		var i = 0
		for segment_blueprint in blueprint.body_segments:
			var bs = BodySegment.new(segment_blueprint)
			bs.name = "BodySegment" + str(i)
			add_child(bs)
			body_segments.append(bs)
			i += 1
