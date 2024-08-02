extends Node2D

var luggage_scene = preload("res://src/Nodes/World/Luggage.tscn")
@export var path: Path2D
@onready var spawn_point = $SpawnPoint

var spawn_timer = 0
var spawn_interval = 2.0
var move_speed = 50
var min_distance = 100

var luggage_list = []

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
		var luggage = path_follow.get_child(0) as RigidBody2D
		if luggage:
			path_follow.progress += move_speed * delta
			luggage.global_position = path_follow.global_position
			luggage.rotation = 0
		
		if path_follow.progress_ratio >= 1:
			luggage_list.erase(path_follow)
			path_follow.queue_free()
