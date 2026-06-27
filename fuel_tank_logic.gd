extends Node2D

func _ready() -> void:
	get_parent().get_parent().fuel += 1500
	get_parent().get_parent().fuelMax += 1500
