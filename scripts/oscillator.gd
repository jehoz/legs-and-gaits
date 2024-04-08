class_name Oscillator extends Node

@export var frequency : float = 1.0
@export var phase : float = 0.0

var elapsed_seconds : float = 0.0

func _init(freq: float = 1.0, phase_offset: float = 0):
	self.frequency = freq
	self.phase = phase_offset

func _process(delta):
	elapsed_seconds += delta * frequency

# SAMPLING FUNCTIONS
func sine(phase_offset: float = 0):
	return sin(elapsed_seconds + phase + phase_offset)

func bias_slope(bias: float, phase_offset: float = 0):
	if bias == 0:
		return self.sine()
	var x = elapsed_seconds + phase + phase_offset
	var k = (2 * atan(bias)) / PI
	return (1.0 / k) * atan2(k * sin(x), 1.0 - k * cos(x))

func bias_peak(bias: float, phase_offset: float = 0):
	if bias == 0:
		return self.sine()
	var x =  elapsed_seconds + phase + phase_offset
	var k = exp(bias)
	return (2.0 * (pow(k, sin(x) + 1.0) - 1.0)) / (pow(k, 2) - 1.0) - 1.0
