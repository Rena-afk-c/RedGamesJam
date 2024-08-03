extends Area2D

@onready var sprite = $Sprite
var is_selected = false
var default_scale = Vector2(0.034, 0.034)
@export var character_type: GameManager.Characters

func _ready():
	input_event.connect(_on_input_event)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	sprite.scale = default_scale
	GameManager.character_selected.connect(_on_character_selected)
	
	# Initialize the outline opacity to 0
	set_outline_opacity(0.0)
	
	# Add this character to the "player" group
	add_to_group("player")

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		select_character()


func select_character():
	GameManager.select_character(character_type)
	is_selected = true
	animate_selection()
	animate_outline(true)

func _on_character_selected(selected_character):
	if selected_character != character_type and is_selected:
		is_selected = false
		animate_selection()
		animate_outline(false)

func animate_selection():
	var tween = create_tween()
	if is_selected:
		tween.tween_property(sprite, "scale", default_scale * 1.2, 0.1)
		tween.tween_property(sprite, "scale", default_scale * 1.1, 0.1)
		tween.parallel().tween_property(sprite, "modulate", Color(1.2, 1.2, 1.2), 0.2)
	else:
		tween.tween_property(sprite, "scale", default_scale * 1.1, 0.1)
		tween.tween_property(sprite, "scale", default_scale, 0.1)
		tween.parallel().tween_property(sprite, "modulate", Color(1, 1, 1), 0.2)

func animate_outline(show: bool):
	var tween = create_tween()
	var target_opacity = 1.0 if show else 0.0
	tween.tween_method(set_outline_opacity, get_outline_opacity(), target_opacity, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func set_outline_opacity(opacity: float):
	sprite.material.set_shader_parameter("outline_opacity", opacity)

func get_outline_opacity() -> float:
	return sprite.material.get_shader_parameter("outline_opacity")

var is_mouse_inside = false

func _on_mouse_entered():
	is_mouse_inside = true

func _on_mouse_exited():
	is_mouse_inside = false

func _process(delta):
	if is_mouse_inside and not is_selected:
		var hover_scale = default_scale * 1.05
		sprite.scale = sprite.scale.lerp(hover_scale, delta * 10)
	elif not is_selected:
		sprite.scale = sprite.scale.lerp(default_scale, delta * 10)
