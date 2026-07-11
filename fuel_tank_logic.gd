extends Node2D

@onready var ship = get_parent().get_parent()
func _ready() -> void:
	ship.fuel += 1500
	ship.fuelMax += 1500
