extends Node2D

signal thrust

@onready var ThrustDirection = $"../ThrustDirection"
@onready var Thruster = $".."
@onready var ThrustParticles = $"../ThrusterParticles"
var ActivationKey

func decide_activation_key() -> void:
	if snappedf(Thruster.rotation,0.01) == 0:
		ActivationKey = "Thrust Forward"
	elif snappedf(Thruster.rotation,0.01) == snappedf((3*PI)/2,0.01):
		ActivationKey = "Thrust Left"
	elif snappedf(Thruster.rotation,0.01) == snappedf(PI/2,0.01):
		ActivationKey = "Thrust Right"
	elif snappedf(Thruster.rotation,0.01) == snappedf(PI,0.01):
		ActivationKey = "Thrust Backward"

func _process(delta: float) -> void:
	ThrustParticles.emitting = true
	if $"..".get_parent().fuel > 0 and get_parent().placeable == false:
		if Input.is_action_pressed(ActivationKey):
			thrust.emit(ThrustDirection.global_position)
		else:
			ThrustParticles.emitting = false
	else:
		ThrustParticles.emitting = false

func _on_thruster_just_placed() -> void:
	#Activates whenever the piece is just pressed
	decide_activation_key()
