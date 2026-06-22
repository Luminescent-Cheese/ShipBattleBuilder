extends Node2D

signal thrust

@onready var ThrustDirection = $"../ThrustDirection"
@onready var Thruster = $".."
func _process(delta: float) -> void:
	if Input.is_action_pressed("Thrust Forward") and snappedf(Thruster.rotation,0.01) == 0:
		thrust.emit(ThrustDirection.global_position)
	elif Input.is_action_pressed("Thrust Left") and snappedf(Thruster.rotation,0.01) == snappedf((3*PI)/2,0.01):
		thrust.emit(ThrustDirection.global_position)
	elif Input.is_action_pressed("Thrust Right") and snappedf(Thruster.rotation,0.01) == snappedf(PI/2,0.01):
		thrust.emit(ThrustDirection.global_position)
	elif Input.is_action_pressed("Thrust Backward") and snappedf(Thruster.rotation,0.01) == snappedf(PI,0.01):
		thrust.emit(ThrustDirection.global_position)
