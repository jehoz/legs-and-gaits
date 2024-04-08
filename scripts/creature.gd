class_name Creature extends Node3D

@export var blueprint: CreatureBlueprint = null

var body_segments: Array[BodySegment] = []

func _enter_tree():
	if blueprint == null:
		return
	
	var body_ik_solver = BodyIKSolver.new()
	body_ik_solver.body_length = blueprint.body_length
	add_child(body_ik_solver)
	
	for i in range(blueprint.num_body_segments):
		var relative_pos = float(i) / blueprint.num_body_segments
		var radius = blueprint.body_shape.sample(1.0 - relative_pos)
		var length = max(0, (blueprint.body_length / blueprint.num_body_segments) - radius)
		var z_offset = relative_pos * blueprint.body_length
		
		var bs = BodySegment.new(radius, length, z_offset)
		bs.name = "BodySegment" + str(i)
		add_child(bs)
		body_segments.append(bs)
		body_ik_solver.segments.append(bs)
	
	blueprint.update_legs()
	body_segments[0].set_legs(blueprint.front_leg_blueprint, 0)
	body_segments[-1].set_legs(blueprint.rear_leg_blueprint, blueprint.leg_pair_phase_difference)

func apply_blueprint_changes():
	if blueprint == null:
		return
	
	blueprint.update_legs()
	body_segments[0].set_legs(blueprint.front_leg_blueprint, 0)
	body_segments[-1].set_legs(blueprint.rear_leg_blueprint, blueprint.leg_pair_phase_difference)
