extends Node3D

@onready var osc : Oscillator = $Oscillator

var origin: Vector3
@export var radius: float = 5.0

func _init():
	origin = position

func _process(_delta):
	position.x = osc.sine() * radius + origin.x
