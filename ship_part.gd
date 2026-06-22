extends Node2D

var TILE_WIDTH
@onready var placeable = true
@onready var tileSprite = $BaseShipSprite

signal thruster_on

func _ready() -> void:
	TILE_WIDTH = tileSprite.get_rect().size.x

func _process(delta: float) -> void:
	place()


func place():
	if placeable:
		global_position = get_global_mouse_position().snapped(Vector2(TILE_WIDTH,TILE_WIDTH))
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			placeable = false
		if Input.is_action_just_pressed("rotate"):
			rotation += PI/2


func _on_thruster_forces_thrust(ThrustDirection) -> void:
	print(self.position.direction_to(ThrustDirection))
	thruster_on.emit(self.global_position.direction_to(ThrustDirection)*100,position)
