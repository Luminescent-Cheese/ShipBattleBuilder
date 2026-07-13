extends Node2D

enum attachability {Bad,Neutral,Good}
@export var Top:attachability
@export var Bottom:attachability
@export var Right:attachability
@export var Left:attachability

@onready var TopArea = $Top
@onready var BottomArea = $Bottom
@onready var RightArea = $Right
@onready var LeftArea = $Left

@onready var ValidPlacement = false

#Checks to see if the tile can be placed Validly when put there
func _on_timer_timeout() -> void:
	ValidPlacement = false
	var checkList = [TopArea,BottomArea,RightArea,LeftArea]
	for i in range(4):
		var CurrentlyChecking = (checkList[i]).get_overlapping_areas()
		if CurrentlyChecking.size() > 0:
			var part = str(CurrentlyChecking[0]).split(":")[0]
			var tile = CurrentlyChecking[0].get_parent()
			var compatibility = tile.get(part)
			#Adds the 2 enum numbers together and decides result off of that
			var checkNum = compatibility + get(str(checkList[i]).split(":")[0])
			if checkNum == 4:
				ValidPlacement = true
			elif (checkNum == 2 and compatibility != 1) or checkNum == 1 or checkNum == 0:
				ValidPlacement = false
				break
