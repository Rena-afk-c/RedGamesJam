extends Area2D

@export var powerup_type: PowerUpsManager.CharacterType
@export var fade_duration: float = 1.0
@export var scale_up_factor: float = 1.2
@export var scale_duration: float = 0.5
@export var rotation_speed: float = 1.0  # Rotation speed in radians per second
@export var glow_intensity: float = 1.5  # Maximum glow intensity
@export var glow_duration: float = 1.0  # Duration of one glow cycle

@onready var icon = $Icon
@onready var collect_zone: Area2D = get_node("/root").find_child("CollectPowerUpZone", true, false)

var is_fading = false
var fade_timer = 0.0
var scale_timer = 0.0
var original_scale: Vector2
var target_rotation: float = 0.0
var in_collection_zone: bool = false
var glow_tween: Tween

func _ready():
	input_pickable = true
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	original_scale = scale
	
	if not collect_zone:
		push_error("CollectPowerUpZone not found in the scene!")
	else:
		collect_zone.area_entered.connect(_on_entered_collection_zone)
		collect_zone.area_exited.connect(_on_exited_collection_zone)
	
	start_glow_effect()

func _process(delta):
	if is_fading:
		process_fading(delta)
	else:
		process_idle_animation(delta)

func process_idle_animation(delta):
	target_rotation += rotation_speed * delta
	rotation = lerp_angle(rotation, target_rotation, 0.1)

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
			activate_powerup()

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

func activate_powerup():
	if not is_fading:
		is_fading = true
		fade_timer = 0.0
		scale_timer = 0.0
		GameManager.power_up_used = true
		PowerUpsManager.activate_powerup(powerup_type)
		GameManager.power_up_used = false

func start_glow_effect():
	glow_tween = create_tween().set_loops()
	glow_tween.tween_property(self, "modulate", Color(glow_intensity, glow_intensity, glow_intensity, 1.0), glow_duration / 2.0)
	glow_tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), glow_duration / 2.0)
