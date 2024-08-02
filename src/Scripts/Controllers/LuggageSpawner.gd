extends Node2D

var luggage_scene = preload("res://src/Nodes/World/Luggage.tscn")
@export var path: Path2D
@onready var spawn_point = $SpawnPoint
var spawn_timer = 0
var spawn_interval = 2.0
var move_speed = 50
var min_distance = 100
var luggage_list = []

func _ready():
	set_process(true)
	set_process_unhandled_input(true)

func _process(delta):
	spawn_timer += delta
	if spawn_timer >= spawn_interval and can_spawn_luggage():
		spawn_luggage()
		spawn_timer = 0
	
	move_luggage(delta)

func can_spawn_luggage() -> bool:
	if luggage_list.is_empty():
		return true
	var last_luggage = luggage_list[luggage_list.size() - 1]
	return last_luggage.progress > min_distance

func spawn_luggage():
	var new_luggage = luggage_scene.instantiate()
	var new_path_follow = PathFollow2D.new()
	
	path.add_child(new_path_follow)
	new_path_follow.add_child(new_luggage)
	
	new_path_follow.progress = 0
	new_path_follow.rotation = 0
	new_luggage.position = Vector2.ZERO
	
	luggage_list.append(new_path_follow)

func move_luggage(delta):
	for path_follow in luggage_list:
		if path_follow.get_child_count() > 0:
			var luggage = path_follow.get_child(0)
			if luggage:
				path_follow.progress += move_speed * delta
				luggage.global_position = path_follow.global_position
				luggage.rotation = 0
		
		if path_follow.progress_ratio >= 1:
			luggage_list.erase(path_follow)
			path_follow.queue_free()

func _unhandled_input(event):
	if (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT) or \
	   (event is InputEventScreenTouch and event.pressed):
		var click_position = get_global_mouse_position()
		check_luggage_click(click_position)

func is_point_inside_collision(collision_shape: CollisionShape2D, point: Vector2) -> bool:
	var shape = collision_shape.shape
	var transform = collision_shape.global_transform
	
	if shape is RectangleShape2D:
		var rect_size = shape.extents * 2
		var rect = Rect2(transform.origin - rect_size / 2, rect_size)
		return rect.has_point(point)
	elif shape is CircleShape2D:
		var distance = transform.origin.distance_to(point)
		return distance <= shape.radius
	
	return false

func can_collect_luggage(luggage: RigidBody2D) -> bool:
	var selected_character = GameManager.get_selected_character()
	match selected_character:
		GameManager.Characters.TAPPY:
			return luggage.luggage_type == luggage.LuggageType.TAPPY
		GameManager.Characters.BIGGIE:
			return luggage.luggage_type == luggage.LuggageType.BIGGIE
		GameManager.Characters.BAM:
			return luggage.luggage_type == luggage.LuggageType.BAM
		GameManager.Characters.OGU:
			return luggage.luggage_type == luggage.LuggageType.OGU
	return false

func collect_luggage(luggage: RigidBody2D, path_follow: PathFollow2D):
	# Check if the luggage is already being collected
	if luggage.get_meta("is_being_collected", false):
		return
	
	# Mark the luggage as being collected
	luggage.set_meta("is_being_collected", true)
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(luggage, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(luggage, "scale", Vector2(1, 1), 0.1).set_delay(0.1)
	tween.tween_property(luggage, "modulate:a", 0, 0.5).set_delay(0.2)
	
	tween.tween_callback(func():
		if is_instance_valid(path_follow) and path_follow.is_inside_tree():
			luggage_list.erase(path_follow)
			path_follow.queue_free()
		GameManager.collect_luggage()
	).set_delay(0.7)

func check_luggage_click(click_position: Vector2):
	for path_follow in luggage_list:
		if path_follow.get_child_count() > 0:
			var luggage = path_follow.get_child(0)
			if luggage is RigidBody2D and is_instance_valid(luggage) and luggage.is_inside_tree():
				var collision_shape = luggage.get_node("CollisionShape2D")
				if collision_shape and is_point_inside_collision(collision_shape, click_position):
					if can_collect_luggage(luggage):
						collect_luggage(luggage, path_follow)
					break
