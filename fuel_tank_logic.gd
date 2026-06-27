extends Node2D

func _ready() -> void:
	get_parent().get_parent().fuel += 1500
