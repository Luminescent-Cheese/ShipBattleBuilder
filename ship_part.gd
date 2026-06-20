extends Node2D

var TILE_WIDTH
@onready var placeable = true
@onready var tileSprite = $BaseShipSprite
func _ready() -> void:
	TILE_WIDTH = tileSprite.get_rect().size.x

func _process(delta: float) -> void:
	place()


func place():
	if placeable:
		global_position = get_global_mouse_position().snapped(Vector2(TILE_WIDTH,TILE_WIDTH))
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			placeable = false
