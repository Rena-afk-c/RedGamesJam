extends Area2D

@export var powerup_type: PowerUpManager.CharacterType
@export var fade_duration: float = 1.0
@export var scale_up_factor: float = 1.2
@export var scale_duration: float = 0.5

@onready var icon = $Icon
@onready var bubble_overlay = $BubbleOverlay

var is_popping = false
var is_fading = false
var pop_progress = 0.0
var pop_speed = 2.0
var shake_amount = 1.0
var shake_duration = 0.2
var shake_timer = 0.0
var fade_timer = 0.0
var scale_timer = 0.0
var original_positions = {}
var original_scale: Vector2

func _ready():
	input_event.connect(_on_input_event)
	
	if bubble_overlay.material is ShaderMaterial:
		bubble_overlay.material.set_shader_parameter("pop_bubble", false)
		bubble_overlay.material.set_shader_parameter("pop_progress", 0.0)
	
	original_positions = {
		"icon": icon.position,
		"bubble_overlay": bubble_overlay.position
	}
	original_scale = scale

func _process(delta):
	if is_popping:
		process_popping(delta)
	elif is_fading:
		process_fading(delta)

func process_popping(delta):
	pop_progress += delta * pop_speed
	bubble_overlay.material.set_shader_parameter("pop_progress", pop_progress)
	
	if shake_timer > 0:
		shake_timer -= delta
		apply_shake()
	elif shake_timer <= 0:
		reset_positions()
		start_fading()

func process_fading(delta):
	fade_timer += delta
	var fade_progress = fade_timer / fade_duration
	modulate.a = 1.0 - fade_progress

	scale_timer += delta
	var scale_progress = min(scale_timer / scale_duration, 1.0)
	var current_scale = original_scale.lerp(original_scale * scale_up_factor, scale_progress)
	scale = current_scale

	if fade_timer >= fade_duration:
		queue_free()

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if can_activate_powerup():
			start_pop_effect()

func can_activate_powerup() -> bool:
	return convert_character_type(GameManager.get_selected_character()) == powerup_type

func convert_character_type(game_character: GameManager.Characters) -> PowerUpManager.CharacterType:
	match game_character:
		GameManager.Characters.TAPPY:
			return PowerUpManager.CharacterType.TAPPY
		GameManager.Characters.BAM:
			return PowerUpManager.CharacterType.BAM
		GameManager.Characters.BIGGIE:
			return PowerUpManager.CharacterType.BIGGIE
		GameManager.Characters.OGU:
			return PowerUpManager.CharacterType.OGU
		_:
			push_error("Invalid character type")
			return PowerUpManager.CharacterType.TAPPY  # Default to TAPPY in case of error

func start_pop_effect():
	if not is_popping and not is_fading:
		is_popping = true
		pop_progress = 0.0
		shake_timer = shake_duration
		bubble_overlay.material.set_shader_parameter("pop_bubble", true)
		
		PowerUpManager.activate_powerup(powerup_type)

func apply_shake():
	var shake_offset = Vector2(randf_range(-shake_amount, shake_amount), randf_range(-shake_amount, shake_amount))
	icon.position = original_positions["icon"] + shake_offset
	bubble_overlay.position = original_positions["bubble_overlay"] + shake_offset

func reset_positions():
	icon.position = original_positions["icon"]
	bubble_overlay.position = original_positions["bubble_overlay"]

func start_fading():
	is_popping = false
	is_fading = true
	fade_timer = 0.0
	scale_timer = 0.0
