extends Area2D

var tween: Tween

func _ready():
	set_process_input(true)
	print("CollectArea initialized")
	
	# Connect to input events
	connect("input_event", Callable(self, "_on_input_event"))

func _on_input_event(_viewport, event, _shape_idx):
	if (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT) or \
	   (event is InputEventScreenTouch and event.pressed):
		print("Valid input detected inside CollectArea")
		on_area_clicked()

func on_area_clicked():
	print("Luggage selected!")
	select_luggage()

func select_luggage():
	print("Selecting luggage")
	var luggage = get_parent()
	
	if tween:
		tween.kill() 
	
	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(luggage, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(luggage, "scale", Vector2(1, 1), 0.1).set_delay(0.1)
	tween.tween_property(luggage, "modulate:a", 0, 0.5).set_delay(0.2)
	tween.tween_callback(luggage.queue_free).set_delay(0.7)

# Optional: Keep these for debugging if needed
func _on_mouse_entered():
	print("Mouse entered CollectArea")

func _on_mouse_exited():
	print("Mouse exited CollectArea")
