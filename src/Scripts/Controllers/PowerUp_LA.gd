extends Area2D

@onready var icon = $Icon
@onready var bubble_overlay = $BubbleOverlay

var is_popping = false
var pop_progress = 0.0
var pop_speed = 2.0  
var shake_amount = 1.0
var shake_duration = 0.2  
var shake_timer = 0.0

var original_positions = {}

func _ready():
	input_event.connect(_on_input_event)
	
	if bubble_overlay.material is ShaderMaterial:
		bubble_overlay.material.set_shader_parameter("pop_bubble", false)
		bubble_overlay.material.set_shader_parameter("pop_progress", 0.0)
	
	original_positions = {
		"icon": icon.position,
		"bubble_overlay": bubble_overlay.position
	}

func _process(delta):
	if is_popping:
		pop_progress += delta * pop_speed
		bubble_overlay.material.set_shader_parameter("pop_progress", pop_progress)
		
		if shake_timer > 0:
			shake_timer -= delta
			apply_shake()
		elif shake_timer <= 0:
			reset_positions()

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		start_pop_effect()

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if get_viewport_rect().has_point(to_local(event.position)):
			start_pop_effect()

func start_pop_effect():
	if not is_popping:
		is_popping = true
		pop_progress = 0.0
		shake_timer = shake_duration
		bubble_overlay.material.set_shader_parameter("pop_bubble", true)


func apply_shake():
	var shake_offset = Vector2(randf_range(-shake_amount, shake_amount), randf_range(-shake_amount, shake_amount))
	icon.position = original_positions["icon"] + shake_offset
	bubble_overlay.position = original_positions["bubble_overlay"] + shake_offset

func reset_positions():
	icon.position = original_positions["icon"]
	bubble_overlay.position = original_positions["bubble_overlay"]
