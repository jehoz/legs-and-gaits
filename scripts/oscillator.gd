class_name Oscillator extends Node

@export var frequency : float = 1.0
@export var phase : float = 0.0

var elapsed_seconds : float = 0.0

func _init(freq: float = 1.0, phase_offset: float = 0):
	self.frequency = freq
	self.phase = phase_offset

func _process(delta):
	elapsed_seconds += delta

# SAMPLING FUNCTIONS
func sine(phase_offset: float = 0):
	return sin(frequency * elapsed_seconds + phase + phase_offset)

func skewed(skew: float, phase_offset: float = 0):
	if skew == 0:
		return self.sine()
	var x = frequency * elapsed_seconds + phase + phase_offset
	skew = clamp(skew, -1.0, 1.0)
	return (1.0 / skew) * atan2(skew * sin(x), 1.0 - skew * cos(x))

func asymmetric(bias: float, phase_offset: float = 0):
	if bias == 0:
		return self.sine()
	var x =  frequency * elapsed_seconds + phase + phase_offset
	var k = pow(2, -bias)
	return (2.0 * (pow(k, sin(x) + 1.0) - 1.0)) / (pow(k, 2) - 1.0) - 1.0
