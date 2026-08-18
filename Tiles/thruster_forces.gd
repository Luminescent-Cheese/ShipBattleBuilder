extends Node2D

signal thrust

@onready var ThrustDirection = $"../ThrustDirection"
@onready var Thruster = $".."
@onready var ThrustParticles = $"../ThrusterParticles"
@onready var EndThrustParticles = $"../EndThrustParticles"
var ActivationKey
var WaitKey = false

var LastKey: String

func decide_activation_key() -> void:
	if snappedf(Thruster.rotation,0.01) == 0:
		ActivationKey = "W"
	elif snappedf(Thruster.rotation,0.01) == snappedf((3*PI)/2,0.01):
		ActivationKey = "A"
	elif snappedf(Thruster.rotation,0.01) == snappedf(PI/2,0.01):
		ActivationKey = "D"
	elif snappedf(Thruster.rotation,0.01) == snappedf(PI,0.01):
		ActivationKey = "S"

func _on_thruster_just_placed() -> void:
	#Activates whenever the piece is just pressed. Decides starting key based off of rotation
	decide_activation_key()


func _on_thruster_clicked() -> void:
	ActivationKey = str(LastKey)
	WaitKey = true

func _on_thruster_new_input(event: Variant) -> void:
	LastKey = event
	if get_parent().get_parent().name == "Ship":
		if $"..".get_parent().fuel > 0 and get_parent().placeable == false:
			if event == ActivationKey:
				ThrustParticles.emitting = true
				EndThrustParticles.stop()
				EndThrustParticles.start()
				thrust.emit(ThrustDirection.global_position)

func _on_end_thrust_particles_timeout() -> void:
	ThrustParticles.emitting = false
