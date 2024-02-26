class_name Leg extends Node3D

@export var femur_length: float = 0.37
@export var tibia_length: float = 0.57
@export var metatarsal_length: float = 0.21
@export var toe_length: float = 0.06
@export var ankle_rise: float = 1.5

enum LegType {LEG_FRONT, LEG_BACK}
@export var leg_type: LegType = LegType.LEG_BACK

@onready var foot_target: Node3D = $FootTarget
@onready var oscillator: Oscillator = $Oscillator
