extends RigidBody2D

@onready var Ship_Part = preload("uid://bnvbyi3c63nr1")
@onready var Thruster = preload("uid://bqt8aindfhcmj")
@onready var Fuel = preload("uid://cjx5kmjalasat")
@onready var MiniGun = preload("uid://cqo60w4va4ss2")
@onready var Debris = preload("res://debris.tscn")

@onready var shipCamera = $ShipCamera
@onready var Core = $Core
#Hud Nodes
@onready var Fuel_Label = $Hud/HudStats/Fuel/FuelBar/FuelBarLabel
@onready var Fuel_Bar = $Hud/HudStats/Fuel/FuelBar
@export var speed:float
@export var current_torque: float
@export var fuel: float = 0.0
@export var fuelMax:float = 0.0

var force_dir = [Vector2.ZERO]
var force_pos = [Vector2.ZERO]

#makes it so you can't place multiple things at once
var canPlace = true

#Doesn't run physics simulations until space is pressed
@onready var isLaunched = false

func _process(delta: float) -> void:
	#Launches Ship once space is pressed
	if Input.is_action_just_pressed("Launch"):
		if not isLaunched:
			recalculate_all_neighbors()
		isLaunched = true
	#used to display that on the hud (future plan)
	speed = linear_velocity.length()
	current_torque = angular_velocity
	Fuel_Label.text = str(int(fuel))+"/"+str(int(fuelMax))
	Fuel_Bar.max_value = fuelMax
	Fuel_Bar.value = fuel
	
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
		if Input.is_action_just_pressed("test3"):
			canPlace = false
			var New_fuel = Fuel.instantiate()
			add_child(New_fuel)
			New_fuel.add_collision.connect(add_collision_shape)
		if Input.is_action_just_pressed("test4"):
			canPlace = false
			var New_gun = MiniGun.instantiate()
			add_child(New_gun)
			New_gun.add_collision.connect(add_collision_shape)
			
	$CenterOfMass.position = Vector2(0,0)
	#always lerps camera back to 0,0 whenever it leaves smoothly
	var weight: float = 1.0 - exp(-10 * delta)
	shipCamera.position = shipCamera.position.lerp(Vector2.ZERO,weight)

func add_collision_shape(set_position, setName):
	#probably should get a better place to put that canPlace in the future
	canPlace = true
	var collision_shape = CollisionShape2D.new()
	collision_shape.position = set_position
	collision_shape.shape = RectangleShape2D.new()
	collision_shape.shape.size = Vector2(128,128)
	collision_shape.name = str(setName)+"collisionShape"
	add_child(collision_shape)
	#Adds new mass per till (In the future this should depend on the specific tile)
	mass += 2
	#recaulculates center of mass
	calculate_center_of_mass()

		
func on_thrust(force_direction,force_position) -> void:
	if isLaunched:
		force_dir.append(force_direction.rotated(global_rotation))
		force_pos.append(force_position)
		
func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
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
			if not child is CanvasLayer:
				child.position -= averagePosition
	#changes global position so it looks like no movement occured
	global_position += averagePosition

func recalculate_all_neighbors():
	for child in get_children():
		if child.is_in_group("Ship_tiles"):
			child.SurrondingCheckCode.check_neighbors()

func calculate_debris(startTile):
	var routes = startTile.tileNeighbors
	#Delete startingTiles CollisionShape2D
	var startCollisionShapeName = str(startTile.name) + "collisionShape"
	startCollisionShapeName = startCollisionShapeName.replace("@","_")
	if get_node(startCollisionShapeName) in get_children():
		get_node(startCollisionShapeName).queue_free()
	recalculate_all_neighbors()
	var visited = []
	var toVisit = []
	for i in range(routes.size()):
		visited.clear()
		toVisit.clear()
		visited.append(routes[i])
		var current = visited[0]
		for tryTile in current.tileNeighbors:
			if not tryTile in visited:
				toVisit.append(tryTile)
		while toVisit.size() > 0:
			current = toVisit[0]
			toVisit.remove_at(0)
			visited.append(current)
			for tryTile in current.tileNeighbors:
				if not tryTile in visited:
					toVisit.append(tryTile)
		if not Core in visited:
			#break off piece of debris
			var newDebris = Debris.instantiate()
			var collisionObject:CollisionShape2D
			for tile in visited:
				tile.reparent(newDebris)
				var collisionShapeName = str(tile.name) + "collisionShape"
				collisionShapeName = collisionShapeName.replace("@","_")
				if get_node(collisionShapeName) in get_children():
					collisionObject = get_node(collisionShapeName)
					collisionObject.reparent(newDebris)
				else:
					print("Collision Shape not found")
			add_sibling(newDebris)
