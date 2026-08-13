extends RigidBody2D

@export var Ship: RigidBody2D
@export var Pivot: Vector2
func _ready() -> void:
	var force_dir = global_position.direction_to(Ship.global_position) * 10000
	apply_force(force_dir,Pivot)
