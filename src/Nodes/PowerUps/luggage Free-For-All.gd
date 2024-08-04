extends Area2D

@export var powerup_type: PowerUpsManager.CharacterType
@export var fade_duration: float = 1.0
@export var scale_up_factor: float = 1.2
@export var scale_duration: float = 0.5
@export var rotation_speed: float = 1.0  # Rotation speed in radians per second

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
var target_rotation: float = 0.0

var collect_zone: Area2D
var in_collection_zone: bool = false

func _ready():
	input_pickable = true  # Ensure the Area2D can receive input events
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	if bubble_overlay.material is ShaderMaterial:
		bubble_overlay.material.set_shader_parameter("pop_bubble", false)
		bubble_overlay.material.set_shader_parameter("pop_progress", 0.0)
	
	original_positions = {
		"icon": icon.position,
		"bubble_overlay": bubble_overlay.position
	}
	original_scale = scale
	
	# Find the CollectPowerUpZone
	collect_zone = get_node("/root").find_child("CollectPowerUpZone", true, false)
	if not collect_zone:
		push_error("CollectPowerUpZone not found in the scene!")
	else:
		# Connect to the CollectPowerUpZone's signals
		collect_zone.area_entered.connect(_on_entered_collection_zone)
		collect_zone.area_exited.connect(_on_exited_collection_zone)

func _process(delta):
	if is_popping:
		process_popping(delta)
	elif is_fading:
		process_fading(delta)
	else:
		process_idle_animation(delta)

func process_idle_animation(delta):
	# Smooth rotation
	target_rotation += rotation_speed * delta
	rotation = lerp_angle(rotation, target_rotation, 0.1)

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
		

func _on_mouse_entered():
	if in_collection_zone and can_activate_powerup():
		Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)

func _on_mouse_exited():
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if in_collection_zone and can_activate_powerup():
			start_pop_effect()
			GameManager.power_up_used = true
			GameManager.power_up_used = false

func _on_entered_collection_zone(area):
	if area == self:
		in_collection_zone = true

func _on_exited_collection_zone(area):
	if area == self:
		in_collection_zone = false
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func can_activate_powerup() -> bool:
	return convert_character_type(GameManager.get_selected_character()) == powerup_type

func convert_character_type(game_character: GameManager.Characters) -> PowerUpsManager.CharacterType:
	match game_character:
		GameManager.Characters.TAPPY:
			return PowerUpsManager.CharacterType.TAPPY
		GameManager.Characters.BAM:
			return PowerUpsManager.CharacterType.BAM
		GameManager.Characters.BIGGIE:
			return PowerUpsManager.CharacterType.BIGGIE
		GameManager.Characters.OGU:
			return PowerUpsManager.CharacterType.OGU
		_:
			push_error("Invalid character type")
			return PowerUpsManager.CharacterType.TAPPY  # Default to TAPPY in case of error

func start_pop_effect():
	if not is_popping and not is_fading:
		is_popping = true
		pop_progress = 0.0
		shake_timer = shake_duration
		bubble_overlay.material.set_shader_parameter("pop_bubble", true)
		
		PowerUpsManager.activate_powerup(powerup_type)

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
