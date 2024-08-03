extends Node2D

enum PowerupType {
	POINT_FRENZY,
	LUGGAGE_FREE_FOR_ALL,
	LUGGAGE_AUTOMATA,
	TIME_SLOW
}

@export var point_frenzy_scene: PackedScene
@export var luggage_free_for_all_scene: PackedScene
@export var luggage_automata_scene: PackedScene
@export var time_slow_scene: PackedScene
@export var path: Path2D
@onready var spawn_point = $SpawnPoint
@onready var pu_detection_zone: Area2D = $PU_DetectionZone

var spawn_timer: float = 0.0
@export var spawn_interval: float = 5.0
@export var move_speed: float = 40.0
@export var min_distance: float = 150.0
@export var fade_duration: float = 3.0
@export var flicker_frequency: float = 0.2
@export var spawn_cooldown: float = 2.0

var powerup_list: Array[PathFollow2D] = []
var available_powerups: Array = []
var can_spawn: bool = true

func _ready():
	if not point_frenzy_scene or not luggage_free_for_all_scene or not luggage_automata_scene or not time_slow_scene:
		push_error("Please assign all powerup scenes in the inspector.")
	reset_available_powerups()
	pu_detection_zone.connect("area_entered", Callable(self, "_on_powerup_detected"))

func _process(delta: float) -> void:
	spawn_timer += delta
	if spawn_timer >= spawn_interval and can_spawn_powerup() and can_spawn:
		spawn_powerup()
		spawn_timer = 0
	
	move_powerups(delta)

func can_spawn_powerup() -> bool:
	if powerup_list.is_empty():
		return true
	var last_powerup = powerup_list[powerup_list.size() - 1]
	return last_powerup.progress > min_distance and not available_powerups.is_empty()

func spawn_powerup() -> void:
	if available_powerups.is_empty():
		reset_available_powerups()
	
	var powerup_type = available_powerups.pop_at(randi() % available_powerups.size())
	var powerup_scene = get_powerup_scene(powerup_type)
	
	if not powerup_scene:
		push_error("Invalid powerup scene for type: " + str(powerup_type))
		return
	
	var new_powerup = powerup_scene.instantiate()
	var new_path_follow = PathFollow2D.new()
	
	path.add_child(new_path_follow)
	new_path_follow.add_child(new_powerup)
	
	new_path_follow.progress = 0
	new_path_follow.rotation = 0
	new_powerup.position = Vector2.ZERO
	
	powerup_list.append(new_path_follow)

func get_powerup_scene(powerup_type: PowerupType) -> PackedScene:
	match powerup_type:
		PowerupType.POINT_FRENZY:
			return point_frenzy_scene
		PowerupType.LUGGAGE_FREE_FOR_ALL:
			return luggage_free_for_all_scene
		PowerupType.LUGGAGE_AUTOMATA:
			return luggage_automata_scene
		PowerupType.TIME_SLOW:
			return time_slow_scene
	return null

func move_powerups(delta: float) -> void:
	var powerups_to_remove = []
	for path_follow in powerup_list:
		if path_follow.get_child_count() > 0:
			var powerup = path_follow.get_child(0)
			if powerup:
				path_follow.progress += move_speed * delta
				powerup.global_position = path_follow.global_position
				powerup.rotation = 0
				
				if path_follow.progress_ratio > 1 or (powerup.has_meta("fading") and powerup.modulate.a <= 0):
					powerups_to_remove.append(path_follow)
	
	for path_follow in powerups_to_remove:
		powerup_list.erase(path_follow)
		path_follow.queue_free()

func _on_powerup_detected(area: Area2D) -> void:
	if area.get_parent() in powerup_list and not area.has_meta("fading"):
		start_flicker_fade_out(area)

func start_flicker_fade_out(powerup: Area2D) -> void:
	powerup.set_meta("fading", true)
	can_spawn = false  # Prevent spawning while fading
	
	var tween = create_tween()
	tween.set_loops(int(fade_duration / flicker_frequency))
	tween.tween_property(powerup, "modulate:a", 0.3, flicker_frequency / 2.0)
	tween.tween_property(powerup, "modulate:a", 0.7, flicker_frequency / 2.0)
	
	tween.chain().tween_property(powerup, "modulate:a", 0.0, fade_duration / 2.0)
	tween.chain().tween_callback(start_spawn_cooldown)

func start_spawn_cooldown() -> void:
	await get_tree().create_timer(spawn_cooldown).timeout
	can_spawn = true

func reset_available_powerups() -> void:
	available_powerups = [
		PowerupType.POINT_FRENZY,
		PowerupType.LUGGAGE_FREE_FOR_ALL,
		PowerupType.LUGGAGE_AUTOMATA,
		PowerupType.TIME_SLOW
	]
