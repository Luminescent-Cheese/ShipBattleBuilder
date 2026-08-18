extends Node2D

var TILE_WIDTH
@export var placeable = true
@export var thrustStrength = 7500
@export var tileHealth = 2
@onready var clickable = false
@onready var overlap = false

@onready var tileSprite = $BaseShipSprite
@onready var SurrondingCheckTimer = $SurroundingTileCheck/SurrondingCheckTimer
@onready var SurrondingCheckCode = $SurroundingTileCheck

signal thruster_on
signal add_collision
signal justPlaced
signal clicked
signal newInput(event)
var tileNeighbors = []

func _ready() -> void:
	TILE_WIDTH = tileSprite.get_rect().size.x
	add_to_group("Ship_tiles")

func _process(delta: float) -> void:
	place()
	if tileHealth <= 0:
		tileHealth = 9999
		destroy_tile()

func on_button_pressed(event):
	newInput.emit(event)

func place():
	if placeable:
		#checks if the tiles position has changed since last frame
		var oldGlobalPosition = global_position
		global_position = get_global_mouse_position().snapped(Vector2(TILE_WIDTH,TILE_WIDTH))
		if not overlap and SurrondingCheckCode.ValidPlacement:
			modulate = Color(0.0, 1.0, 0.376, 1.0)
		else:
			modulate = Color(1.0, 0.0, 0.0, 1.0)
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and overlap == false and SurrondingCheckCode.ValidPlacement:
			placeable = false
			modulate = Color(1.0, 1.0, 1.0, 1.0)
			add_collision.emit(position, name)
			justPlaced.emit()
		if Input.is_action_just_pressed("rotate"):
			rotation += PI/2
			if snappedf(rotation,0.01) == snappedf(2*PI,0.01):
				rotation = 0.0
			SurrondingCheckTimer.start()
		if global_position != oldGlobalPosition:
			SurrondingCheckTimer.start()

func _on_thruster_forces_thrust(ThrustDirection) -> void:
	#makes sure craft has fuel (and thrust strength)
	if get_parent().fuel > 0:
		thruster_on.emit(transform.y*-thrustStrength,global_position-get_parent().global_position)
		if get_parent().isLaunched:
			get_parent().fuel -= 1


func _on_check_if_valid_body_entered(body: Node2D) -> void:
#for tiles getting shot
	if body.is_in_group("Bullets"):
		tileHealth -= 1
		body.queue_free()

#checks if its been clicked
func _on_check_if_valid_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if clickable:
				clicked.emit()
			else:
				clickable = true
	#makes sure that it isn't opened when first spawned in

func destroy_tile():
	#makes it so tile no longer counts as a neighbor to other tiles
	SurrondingCheckCode.Top = 1
	SurrondingCheckCode.Bottom = 1
	SurrondingCheckCode.Right = 1
	SurrondingCheckCode.Left = 1
	get_parent().calculate_debris(self)
	$Explosion.emitting = true
	$BaseShipSprite.visible = false
	
func _on_clicked() -> void:
	#TEST CODE for damage
	if Input.is_action_pressed("Launch"):
		destroy_tile()


func _on_explosion_finished() -> void:
	queue_free()


func _on_check_if_valid_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if placeable:
		overlap = true


func _on_check_if_valid_area_shape_exited(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if placeable:
		overlap = false
