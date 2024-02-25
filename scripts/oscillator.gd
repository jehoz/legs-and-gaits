class_name Oscillator extends Node

@export var frequency : float = 1.0
@export var phase : float = 0.0

var elapsed_seconds : float = 0.0
	
func _process(delta):
	elapsed_seconds += delta
	
# SAMPLING FUNCTIONS
func sine():
	return sin(frequency * elapsed_seconds + phase)
	
func skewed(skew: float):
	if skew == 0:
		return self.sine()
	var x = frequency * elapsed_seconds + phase
	skew = clamp(skew, -1.0, 1.0)
	return (1.0 / skew) * atan2(skew * sin(x), 1.0 - skew * cos(x))
