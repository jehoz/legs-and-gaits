class_name BodyIKSolver extends Node

# sequence of body segments on which to perform IK.
# the first and last in the array will be treated as "independent"
# segments whose positions are taken as fact, and will not be modified.
# the rest of the segments in between will be rotated and repositioned so that
# they interpolate between the independent segments as smoothly as possible.
var segments: Array[BodySegment] = []

var body_length: float = 1.0

func _process(_delta: float):
	# not "true" IK, but repositions and orients each body segment smoothly 
	# between the front and back using a bezier curve
	
	var control_points = [
		segments[0].global_position,
		segments[0].global_position + segments[0].global_basis.z * (body_length / 2),
		segments[-1].global_position + -segments[0].global_basis.z * (body_length / 2),
		segments[-1].global_position
	]
	var n = control_points.size()
	
	for i in range(1, segments.size()-1):
		var t = float(i) / segments.size()
		var curve_pt = Vector3(0, 0, 0)
		var w = [1, 3, 3, 1]
		for j in range(n):
			curve_pt.x += control_points[j].x * pow(1-t, (n-1)-j) * pow(t, j) * w[j]
			curve_pt.y += control_points[j].y * pow(1-t, (n-1)-j) * pow(t, j) * w[j]
			curve_pt.z += control_points[j].z * pow(1-t, (n-1)-j) * pow(t, j) * w[j]
		segments[i].global_position = curve_pt
		
	for i in range(1, segments.size()-1):
		var direction = segments[i+1].global_position - segments[i-1].global_position
		var look_target = segments[i].global_position + direction
		segments[i].look_at(look_target, Vector3.UP)
