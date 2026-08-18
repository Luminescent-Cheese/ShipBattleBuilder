extends RigidBody2D

@export var Ship: RigidBody2D
@export var Pivot: Vector2
@export var Core: Node2D
@onready var Debris = preload("res://debris.tscn")

func _ready() -> void:
	var force_dir = global_position.direction_to(Ship.global_position) * 10000
	apply_force(force_dir,Pivot)
	calculate_center_of_mass()

func _process(delta: float) -> void:
	$Sprite2D.position = Vector2.ZERO

func recalculate_all_neighbors():
	for child in get_children():
		if child.is_in_group("Ship_tiles"):
			child.SurrondingCheckCode.check_neighbors()

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
	
func calculate_debris(startTile):
	var routes = startTile.tileNeighbors
	if startTile == Core:
		if routes.size() >= 1:
			Core = routes[0]
		else:
			return
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


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		print(get_children())
		print("-------------------------------------------------------------------------------------------------------------------------------------------------------------------------")
