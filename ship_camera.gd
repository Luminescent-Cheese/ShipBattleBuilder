extends Camera2D
@onready var camera = $"."
@onready var targetZoom = Vector2(0.6,0.6)

#controls player camera movements (pan + zoom)
func _input(event: InputEvent) -> void:
	#changes target zoom (scroll-wheel mouse)
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_in()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_out()
	#changes target zoom (Mac magic mouse)
	if event is InputEventPanGesture:
		var scroll_direction = sign(event.delta.y)
		if scroll_direction > 0:
			zoom_in()
		elif scroll_direction < 0:
			zoom_out()
func _process(delta: float) -> void:
	#interpolation for camera zoom so its smooth (and makes it so you zoom into where your mouse is)
	camera.zoom = camera.zoom.lerp(targetZoom, 10*delta)

func zoom_in():
	if targetZoom < Vector2(1.2,1.2):
		targetZoom += Vector2(.05,.05)

func zoom_out():
	if targetZoom > Vector2(.25,.25):
		targetZoom -= Vector2(.05,.05)
