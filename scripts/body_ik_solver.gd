class_name BodyIKSolver extends Node

# sequence of body segments on which to perform IK.
# the first and last in the array will be treated as "independent"
# segments whose positions are taken as fact, and will not be modified.
# the rest of the segments in between will be rotated and repositioned so that
# they interpolate between the independent segments as smoothly as possible.
var segments: Array[BodySegment] = []

func _process(_delta: float):
	# very simple stupid temporary implementation
	var y0 = segments[0].position.y
	var y1 = segments[-1].position.y
	var z0 = segments[0].z_offset
	var z1 = segments[-1].z_offset
	for i in range(1, segments.size()-1):
		var segment = segments[i]
		var z_percent = abs(segment.z_offset - z0) / abs(z1 - z0)
		segment.position.y = y0 * (1 - z_percent) + y1 * z_percent

func distance_from_target(angles: Array[Vector3]):
	pass

func comfort():
	pass
