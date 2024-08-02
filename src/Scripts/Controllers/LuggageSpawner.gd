extends Node2D

var luggage_scene = preload("res://src/Nodes/World/Luggage.tscn")
@export var path: Path2D
@onready var spawn_point = $SpawnPoint
var spawn_timer: float = 0.0
var spawn_interval: float = 2.0
var move_speed: float = 50.0
var min_distance: float = 100.0
var luggage_list: Array[PathFollow2D] = []
@onready var collection_points = {
	GameManager.Characters.TAPPY: $CollectPointRoot/TappyCollectPoint,
	GameManager.Characters.BIGGIE: $CollectPointRoot/BiggieCollectPoint,
	GameManager.Characters.BAM: $CollectPointRoot/BamCollectPoint,
	GameManager.Characters.OGU: $CollectPointRoot/OguCollectPoint
}
var active_collection_point: Area2D

@export var glow_fade_time: float = 0.3  # Time for the glow to fade in/out

func _ready():
	GameManager.character_selected.connect(_on_character_changed)
	update_active_collection_point()

func _process(delta: float) -> void:
	spawn_timer += delta
	if spawn_timer >= spawn_interval and can_spawn_luggage():
		spawn_luggage()
		spawn_timer = 0
	
	move_luggage(delta)
	update_luggage_highlight()

func can_spawn_luggage() -> bool:
	if luggage_list.is_empty():
		return true
	var last_luggage = luggage_list[luggage_list.size() - 1]
	return last_luggage.progress > min_distance

func spawn_luggage() -> void:
	var new_luggage = luggage_scene.instantiate()
	var new_path_follow = PathFollow2D.new()
	
	path.add_child(new_path_follow)
	new_path_follow.add_child(new_luggage)
	
	new_path_follow.progress = 0
	new_path_follow.rotation = 0
	new_luggage.position = Vector2.ZERO
	
	# Ensure the GlowLight is initially faded out
	var glow_light = new_luggage.get_node("GlowLight")
	if glow_light:
		glow_light.energy = 0
	
	luggage_list.append(new_path_follow)

func move_luggage(delta: float) -> void:
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

func _unhandled_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT) or \
	   (event is InputEventScreenTouch and event.pressed):
		var click_position = get_global_mouse_position()
		check_luggage_click(click_position)

func check_luggage_click(click_position: Vector2) -> void:
	if not active_collection_point:
		return
	
	for path_follow in luggage_list:
		if path_follow.get_child_count() > 0:
			var luggage = path_follow.get_child(0)
			if luggage is RigidBody2D and is_instance_valid(luggage) and luggage.is_inside_tree():
				var luggage_area = luggage.get_node_or_null("CollectionPointArea")
				if luggage_area and luggage_area.overlaps_area(active_collection_point):
					var collision_shape = luggage.get_node_or_null("CollisionShape2D")
					if collision_shape and is_point_inside_collision(collision_shape, click_position):
						if can_collect_luggage(luggage):
							collect_luggage(luggage, path_follow)
						break

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
	return luggage.luggage_type == selected_character

func collect_luggage(luggage: RigidBody2D, path_follow: PathFollow2D) -> void:
	if luggage.get_meta("is_being_collected", false):
		return
	
	luggage.set_meta("is_being_collected", true)
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(luggage, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(luggage, "scale", Vector2(1, 1), 0.1).set_delay(0.1)
	tween.tween_property(luggage, "modulate:a", 0, 0.5).set_delay(0.2)
	
	# Fade out the GlowLight when collecting
	var glow_light = luggage.get_node("GlowLight")
	if glow_light:
		tween.tween_property(glow_light, "energy", 0, glow_fade_time)
	
	tween.tween_callback(func():
		if is_instance_valid(path_follow) and path_follow.is_inside_tree():
			luggage_list.erase(path_follow)
			path_follow.queue_free()
		GameManager.collect_luggage()
	).set_delay(0.7)

func update_active_collection_point() -> void:
	var selected_character = GameManager.get_selected_character()
	
	# Disable all collection points
	for point in collection_points.values():
		point.set_deferred("monitoring", false)
		point.set_deferred("monitorable", false)
	
	# Enable the active collection point
	active_collection_point = collection_points.get(selected_character)
	if active_collection_point:
		active_collection_point.set_deferred("monitoring", true)
		active_collection_point.set_deferred("monitorable", true)

func _on_character_changed(character: GameManager.Characters) -> void:
	update_active_collection_point()
	print("LuggageSpawner: Character changed to ", GameManager.Characters.keys()[character])

func update_luggage_highlight() -> void:
	for path_follow in luggage_list:
		if path_follow.get_child_count() > 0:
			var luggage = path_follow.get_child(0)
			if luggage is RigidBody2D and is_instance_valid(luggage) and luggage.is_inside_tree():
				var luggage_area = luggage.get_node_or_null("CollectionPointArea")
				var glow_light = luggage.get_node("GlowLight")
				if luggage_area and active_collection_point and luggage_area.overlaps_area(active_collection_point):
					if can_collect_luggage(luggage):
						fade_in_glow_light(glow_light)
					else:
						fade_out_glow_light(glow_light)
				else:
					fade_out_glow_light(glow_light)

func fade_in_glow_light(glow_light: PointLight2D) -> void:
	if glow_light and glow_light.energy < 1.0:
		var tween = create_tween()
		tween.tween_property(glow_light, "energy", 1.0, glow_fade_time)

func fade_out_glow_light(glow_light: PointLight2D) -> void:
	if glow_light and glow_light.energy > 0.0:
		var tween = create_tween()
		tween.tween_property(glow_light, "energy", 0.0, glow_fade_time)
