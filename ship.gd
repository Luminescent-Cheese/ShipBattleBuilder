extends Node2D

@onready var Ship_Part = preload("res://ship_part.tscn")
@onready var Thruster = preload("res://thruster.tscn")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("test"):
		var New_part = Ship_Part.instantiate()
		add_child(New_part)
	if Input.is_action_just_pressed("test2"):
		var New_thruster = Thruster.instantiate()
		add_child(New_thruster)
