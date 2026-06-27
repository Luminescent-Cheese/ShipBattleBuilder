extends Node2D

var TILE_WIDTH
@onready var placeable = true
@onready var clickable = false
@onready var overlap = false
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
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and overlap == false:
			placeable = false
			tileSprite.self_modulate = Color(1.0, 1.0, 1.0, 1.0)
			add_collision.emit(position)
		if Input.is_action_just_pressed("rotate"):
			rotation += PI/2
			if snappedf(rotation,0.01) == snappedf(2*PI,0.01):
				rotation = 0.0


func _on_thruster_forces_thrust(ThrustDirection) -> void:
	#makes sure craft has fuel
	if get_parent().fuel > 0:
		thruster_on.emit(transform.y*-1500,global_position-get_parent().global_position)
		get_parent().fuel -= 1


func _on_check_if_valid_body_entered(body: Node2D) -> void:
	if placeable:
		overlap = true
		tileSprite.self_modulate = Color(1.0, 0.0, 0.0, 1.0)


func _on_check_if_valid_body_exited(body: Node2D) -> void:
	if placeable:
		overlap = false
		tileSprite.self_modulate = Color(0.0, 1.0, 0.376, 1.0)

#checks if its been clicked
func _on_check_if_valid_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if clickable:
				print(self)
			else:
				clickable = true
	#makes sure that it isn't opened when first spawned in
