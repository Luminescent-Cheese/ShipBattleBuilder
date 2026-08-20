extends RigidBody2D

@export var isLaunched: bool
@export var fuel = 0
@export var fuelMax = 0
@onready var Core = $Core
@onready var Debris = preload("res://debris.tscn")

var force_dir = [Vector2.ZERO]
var force_pos = [Vector2.ZERO]

func _ready() -> void:
	#adds collision shapes to all children
	for child in get_children():
		if child is Node2D:
			child.placeable = false
			add_collision_shape(child.position, child.name)


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
	
func add_collision_shape(set_position, setName):
	#probably should get a better place to put that canPlace in the future
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
	
func recalculate_all_neighbors():
	for child in get_children():
		if child.is_in_group("Ship_tiles"):
			child.SurrondingCheckCode.check_neighbors()

func calculate_debris(startTile):
	if startTile == Core:
		print("oop")
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
					print(get_node(collisionShapeName))
					collisionObject = get_node(collisionShapeName)
					collisionObject.reparent(newDebris)
				else:
					pass
					print("Collision Shape not found")
			newDebris.Ship = self
			newDebris.Pivot = visited[0].global_position
			newDebris.Core = visited[0]
			#Matches Debris velocity and angular velocity with ship
			newDebris.linear_velocity = linear_velocity
			newDebris.angular_velocity = angular_velocity
			add_sibling(newDebris)
	calculate_center_of_mass()
