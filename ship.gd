extends RigidBody2D

@onready var Ship_Part = preload("res://ship_part.tscn")
@onready var Thruster = preload("res://thruster.tscn")

@onready var shipCamera = $ShipCamera

@export var speed:float
@export var current_torque: float

var force_dir = [Vector2.ZERO]
var force_pos = [Vector2.ZERO]

#makes it so you can't place multiple things at once
var canPlace = true

func _process(delta: float) -> void:
	#used to display that on the hud (future plan)
	speed = linear_velocity.length()
	current_torque = angular_velocity
	
	#print(speed," : ",current_torque)
	if canPlace:
		if Input.is_action_just_pressed("test"):
			canPlace = false
			var New_part = Ship_Part.instantiate()
			add_child(New_part)
			New_part.add_collision.connect(add_collision_shape)
		if Input.is_action_just_pressed("test2"):
			canPlace = false
			var New_thruster = Thruster.instantiate()
			add_child(New_thruster)
			New_thruster.thruster_on.connect( on_thrust)
			New_thruster.add_collision.connect(add_collision_shape)
			
	$CenterOfMass.position = Vector2(0,0)
	#always lerps camera back to 0,0 whenever it leaves smoothly
	var weight: float = 1.0 - exp(-10 * delta)
	shipCamera.position = shipCamera.position.lerp(Vector2.ZERO,weight)

func add_collision_shape(set_position):
	#probably should get a better place to put that canPlace in the future
	canPlace = true
	var collision_shape = CollisionShape2D.new()
	collision_shape.position = set_position
	collision_shape.shape = RectangleShape2D.new()
	collision_shape.shape.size = Vector2(128,128)
	add_child(collision_shape)
	mass += 5
	#recaulculates center of mass
	calculate_center_of_mass()

		
func on_thrust(force_direction,force_position) -> void:
	force_dir.append(force_direction.rotated(global_rotation))
	force_pos.append(force_position)

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	print(force_pos)
	for i in force_dir.size():
		apply_force(force_dir[i],force_pos[i])
	if force_dir.size() > 1:
		force_dir.clear()
		force_pos.clear()
		force_dir.append(Vector2.ZERO)
		force_pos.append(Vector2.ZERO)

func calculate_center_of_mass():
	var positions = []
	var averagePosition = Vector2.ZERO
	#finds where new center of mass should be
	for child in get_children():
		if child is CollisionShape2D:
			positions.append(child.position)
	for i in positions.size():
		averagePosition += positions[i]
	averagePosition /= positions.size()
	#makes it so that point becomes (0,0) locally
	for child in get_children():
			child.position -= averagePosition
	#changes global position so it looks like no movement occured
	global_position += averagePosition
