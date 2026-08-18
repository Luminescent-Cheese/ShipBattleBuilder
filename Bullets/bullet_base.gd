extends CharacterBody2D

@export var SPEED: float = 2000.0
@export var shoot_dir: Vector2 = Vector2.ZERO
@export var damage: float = 5.0
@export var parentVelocity: Vector2 = Vector2.ZERO
func _ready() -> void:
	$"Bullet Sprite".visible = false
	$"Bullet Collision".disabled = true
func _physics_process(delta: float) -> void:
	velocity = (SPEED * shoot_dir)+ parentVelocity
	move_and_slide()

func _on_deletion_timer_timeout() -> void:
	queue_free()


func _on_apperance_timer_timeout() -> void:
	$"Bullet Sprite".visible = true
	$"Bullet Collision".disabled = false
