extends Node2D

signal thrust

@onready var ThrustDirection = $"../ThrustDirection"
func _process(delta: float) -> void:
	if Input.is_action_pressed("Thrust Forward"):
		thrust.emit(ThrustDirection.global_position)
