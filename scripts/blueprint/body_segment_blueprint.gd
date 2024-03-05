class_name BodySegmentBlueprint extends Resource

@export var radius: float = 0.2
@export var leg_blueprint: LegBlueprint = null

# populated by parent blueprint
var _speed: float = 1.0
var _phase_offset: float = 0
