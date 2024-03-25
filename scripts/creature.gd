class_name Creature extends Node3D

@export var blueprint: CreatureBlueprint = null

var body_segments: Array[BodySegment] = []

func _enter_tree():
	if blueprint == null:
		return
	
	var body_ik_solver = BodyIKSolver.new()
	add_child(body_ik_solver)
	
	var leg_pair = 0
	var last_segment_z = 0
	var i = 0
	for segment_blueprint in blueprint.body_segments:
		segment_blueprint._speed = blueprint.speed
		segment_blueprint._phase_offset = leg_pair * blueprint.leg_pair_phase_difference
		segment_blueprint._z_offset = last_segment_z + segment_blueprint.length
		last_segment_z = segment_blueprint._z_offset
		
		var bs = BodySegment.new(segment_blueprint)
		bs.name = "BodySegment" + str(i)
		add_child(bs)
		body_segments.append(bs)
		body_ik_solver.segments.append(bs)
		i += 1
		if segment_blueprint.leg_blueprint:
			leg_pair += 1

func propagate_blueprint_changes():
	if blueprint == null:
		return
	
	for i in range(body_segments.size()):
		var segment = body_segments[i]
		var segment_blueprint = blueprint.body_segments[i]
		# for now pretend legs will always stay where they are
		if segment_blueprint.leg_blueprint != null:
			segment.leg_l.update_from_blueprint(segment_blueprint.leg_blueprint)
			segment.leg_r.update_from_blueprint(segment_blueprint.leg_blueprint)
