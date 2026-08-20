extends Node2D
@onready var bullet = preload("res://Bullets/bullet_base.tscn")
@onready var aim = $"../AimMark"
@onready var ShotCooldown = $"../ShotCooldown"
@onready var GunParticles = $"../GunFireParticle"

@onready var canShoot = true
@onready var lastPos = global_position
@onready var currentPos = global_position

@onready var frameDelta = Vector2.ZERO
func _process(delta: float) -> void:
	lastPos = currentPos
	currentPos = global_position
	frameDelta = (currentPos-lastPos)/delta

func fire_bullet():
	var FireBullet = bullet.instantiate()
	FireBullet.global_position = global_position
	FireBullet.shoot_dir = (aim.global_position - global_position).normalized()
	FireBullet.parentVelocity = frameDelta
	get_parent().get_parent().get_parent().add_child(FireBullet)

func _on_shot_cooldown_timeout() -> void:
	canShoot = true


func _on_mini_gun_new_input(event: Variant) -> void:
	if event == "Space" and canShoot:
		GunParticles.emitting = true
		fire_bullet()
		canShoot = false
		ShotCooldown.start()
