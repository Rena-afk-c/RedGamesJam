extends Node2D

var luggage_scene = preload("res://src/Nodes/World/Luggage.tscn")

@export var path: Path2D
@onready var spawn_point = $SpawnPoint
var spawn_timer: float = 0.0
@export var spawn_interval: float = 2.0
var move_speed: float = 50.0
var min_distance: float = 100.0
var luggage_list: Array[PathFollow2D] = []
var _paused: bool = false

@onready var game_over = $"../GameOver"
@onready var collection_points = {
	GameManager.Characters.TAPPY: $CollectPointRoot/TappyCollectPoint,
	GameManager.Characters.BIGGIE: $CollectPointRoot/BiggieCollectPoint,
	GameManager.Characters.BAM: $CollectPointRoot/BamCollectPoint,
	GameManager.Characters.OGU: $CollectPointRoot/OguCollectPoint
}

var active_collection_point: Area2D

func _ready():
	AudioManager.play_main_menu_bg_music()
	AudioManager.fade_in_audio(1.0)
	game_over.hide()
	GameManager.character_selected.connect(_on_character_changed)
	update_active_collection_point()
	PowerUpEffects.connect("luggage_free_for_all_activated", Callable(self, "_on_luggage_free_for_all_activated"))
	PowerUpEffects.connect("luggage_free_for_all_deactivated", Callable(self, "_on_luggage_free_for_all_deactivated"))
	GameManager.connect("game_over", Callable(self, "_on_game_over"))

func _process(delta: float) -> void:
	if _paused:
		return
	
	spawn_timer += delta
	if spawn_timer >= spawn_interval and can_spawn_luggage():
		spawn_luggage()
		spawn_timer = 0
	
	move_luggage(delta)
	if luggage_list.size() >= 3:
		game_over.show()
		game_over.Game_Over_Utilize(GameManager.high_score,GameManager.tickets)

func pause_spawner():
	_paused = true
	set_process(false)
	set_physics_process(false)
	for path_follow in luggage_list:
		if path_follow.get_child_count() > 0:
			var luggage = path_follow.get_child(0)
			if luggage is Node2D:
				luggage.set_process(false)
				luggage.set_physics_process(false)
			if luggage is RigidBody2D:
				luggage.freeze = true

func resume_spawner():
	_paused = false
	set_process(true)
	set_physics_process(true)
	for path_follow in luggage_list:
		if path_follow.get_child_count() > 0:
			var luggage = path_follow.get_child(0)
			if luggage is Node2D:
				luggage.set_process(true)
				luggage.set_physics_process(true)
			if luggage is RigidBody2D:
				luggage.freeze = false

func can_spawn_luggage() -> bool:
	if luggage_list.is_empty():
		return true
	var last_luggage = luggage_list[luggage_list.size() - 1]
	return last_luggage.progress > min_distance

func spawn_luggage() -> void:
	if _paused:
		return
	
	AudioManager.drop_luggage_sfx()
	var new_luggage = luggage_scene.instantiate()
	var new_path_follow = PathFollow2D.new()
	
	path.add_child(new_path_follow)
	new_path_follow.add_child(new_luggage)
	
	new_path_follow.progress = 0
	new_path_follow.rotation = 0
	new_luggage.position = Vector2.ZERO
	
	luggage_list.append(new_path_follow)
	GameManager.increment_luggage_count()

func move_luggage(delta: float) -> void:
	if _paused:
		return
	
	var luggage_to_remove = []
	for path_follow in luggage_list:
		if path_follow.get_child_count() > 0:
			var luggage = path_follow.get_child(0)
			if luggage:
				path_follow.progress += move_speed * delta
				luggage.global_position = path_follow.global_position
				luggage.rotation = 0
		
		if path_follow.progress_ratio >= 1:
			luggage_to_remove.append(path_follow)
	
	for path_follow in luggage_to_remove:
		luggage_list.erase(path_follow)
		GameManager.decrement_luggage_count()
		path_follow.queue_free()

func _unhandled_input(event: InputEvent) -> void:
	if _paused:
		return
	
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
	return PowerUpEffects.active_powerups[PowerUpsManager.PowerUpType.LUGGAGE_FREE_FOR_ALL] or luggage.luggage_type == selected_character

func collect_luggage(luggage: RigidBody2D, path_follow: PathFollow2D) -> void:
	GameManager.collect_ticket()
	AudioManager.pick_up_luggage_sfx()
	if luggage.get_meta("is_being_collected", false):
		return
	
	luggage.set_meta("is_being_collected", true)
	
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Pop-up effect
	tween.tween_property(luggage, "scale", Vector2(1.3, 1.3), 0.15).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(luggage, "scale", Vector2(0.1, 0.1), 0.35).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK).set_delay(0.15)
	
	# Rotation effect
	tween.tween_property(luggage, "rotation", randf_range(-PI, PI), 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	
	# Fade out
	tween.tween_property(luggage, "modulate:a", 0, 0.35).set_delay(0.15)
	
	# Move towards collection point
	var collection_point_pos = active_collection_point.global_position
	tween.tween_property(luggage, "global_position", collection_point_pos, 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	
	# Fade out the GlowLight
	var glow_light = luggage.get_node_or_null("GlowLight")
	if glow_light and glow_light is PointLight2D:
		tween.tween_property(glow_light, "energy", 0, 0.25)
	
	tween.tween_callback(func():
		if is_instance_valid(path_follow) and path_follow.is_inside_tree():
			luggage_list.erase(path_follow)
			path_follow.queue_free()
		GameManager.collect_luggage()
		GameManager.decrement_luggage_count()
	).set_delay(0.5)

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

func _on_luggage_free_for_all_activated():
	print("Luggage Free-For-All activated in LuggageSpawner")

func _on_luggage_free_for_all_deactivated():
	print("Luggage Free-For-All deactivated in LuggageSpawner")

func _on_game_over():
	AudioManager.game_over()
	pause_spawner()
	
	for path_follow in luggage_list:
		if path_follow.get_child_count() > 0:
			var luggage = path_follow.get_child(0)
			if luggage is RigidBody2D:
				var tween = create_tween()
				tween.tween_property(luggage, "modulate:a", 0, 1.0)
	
	await get_tree().create_timer(2.0).timeout
	GameManager.restart_game()
