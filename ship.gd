extends Node2D

@onready var Ship_Part = preload("res://ship_part.tscn")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("test"):
		print("test")
		var New_part = Ship_Part.instantiate()
		add_child(New_part)
