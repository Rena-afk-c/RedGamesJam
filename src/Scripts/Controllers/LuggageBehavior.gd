extends Area2D

@export var rotation_speed: float = 2.0  
var is_interacted: bool = false
var progress: float = 0.0

func _ready() -> void:
	add_to_group("luggage")

func _process(delta: float) -> void:
	if not is_interacted:
		rotate(rotation_speed * delta)

func interact() -> void:
	is_interacted = true
