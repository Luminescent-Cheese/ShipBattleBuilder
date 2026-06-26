extends Node2D

var TILE_WIDTH
@onready var placeable = true
@onready var tileSprite = $BaseShipSprite

signal thruster_on
signal add_collision
func _ready() -> void:
	TILE_WIDTH = tileSprite.get_rect().size.x

func _process(delta: float) -> void:
	place()


func place():
	if placeable:
		global_position = get_global_mouse_position().snapped(Vector2(TILE_WIDTH,TILE_WIDTH))
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			placeable = false
			add_collision.emit(position)
		if Input.is_action_just_pressed("rotate"):
			rotation += PI/2
			if snappedf(rotation,0.01) == snappedf(2*PI,0.01):
				rotation = 0.0


func _on_thruster_forces_thrust(ThrustDirection) -> void:
	thruster_on.emit(global_position+transform.y*-500,global_position-get_parent().global_position)
	$"thrust center".global_position = global_position
	$"thrust direction".global_position = (transform.y)*200
	#print("thrust center = %s, dir = %s" % [$"thrust center".global_position, $"thrust direction".global_position])
