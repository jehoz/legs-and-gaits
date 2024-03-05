class_name CreatureBlueprint extends Resource

@export var body_segments: Array[BodySegmentBlueprint] = []
@export var speed: float = 1.0

## Difference in oscillator phases between front and back legs
@export var leg_pair_phase_difference = PI/2
