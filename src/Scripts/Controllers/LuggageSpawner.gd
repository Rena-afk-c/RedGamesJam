# LuggageSpawner.gd
extends Node2D

@export var spawn_interval: float = 3.0  # Seconds
@export var luggage_scene: PackedScene

@onready var conveyor_belt: Path2D = get_parent().get_node("ConveyorBelt")

func _ready() -> void:
	$Timer.wait_time = spawn_interval
	$Timer.start()

func _on_Timer_timeout() -> void:
	var luggage = luggage_scene.instantiate()
	luggage.progress = 0  # Start at the beginning of the path
	conveyor_belt.path_follow.add_child(luggage)
