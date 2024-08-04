extends CanvasLayer

@onready var bg = $BG
@onready var icon = $Icon
@onready var name_label = $NameLabel
@export var transition_duration: float = 1.0

enum TransitionType {
	NONE,
	FADE,
	ICON_AND_TEXT
}

var next_scene: String = ""
var current_transition: TransitionType = TransitionType.NONE

func _ready():
	# Ensure all elements are invisible at start
	bg.color = Color(0, 0, 0, 0)  # Fully transparent black background
	icon.modulate.a = 0
	name_label.modulate.a = 0
	
	# Set initial positions
	icon.position.y += 50
	name_label.position.y += 50
	
	# Hide the entire transition layer initially
	hide()

func transition(target_scene: String, type: TransitionType = TransitionType.NONE):
	next_scene = target_scene
	current_transition = type
	
	match type:
		TransitionType.NONE:
			perform_scene_change()
		TransitionType.FADE:
			fade_transition()
		TransitionType.ICON_AND_TEXT:
			icon_and_text_transition()

func fade_transition():
	show()
	var tween = create_tween()
	tween.tween_property(bg, "color:a", 1.0, transition_duration * 0.5)
	tween.tween_callback(perform_scene_change)
	tween.tween_interval(0.1)
	tween.tween_property(bg, "color:a", 0.0, transition_duration * 0.5)
	tween.tween_callback(hide)

func icon_and_text_transition():
	show()
	var tween = create_tween()
	
	# Fade in and animate icon and name label
	tween.parallel().tween_property(bg, "color:a", 1.0, transition_duration * 0.25)
	tween.parallel().tween_property(icon, "modulate:a", 1.0, transition_duration * 0.5)
	tween.parallel().tween_property(icon, "position:y", icon.position.y - 50, transition_duration * 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.parallel().tween_property(name_label, "modulate:a", 1.0, transition_duration * 0.5)
	tween.parallel().tween_property(name_label, "position:y", name_label.position.y - 50, transition_duration * 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	
	# Pause
	tween.tween_interval(transition_duration)
	
	# Start fading out
	tween.parallel().tween_property(icon, "modulate:a", 0.0, transition_duration * 0.5)
	tween.parallel().tween_property(icon, "position:y", icon.position.y - 20, transition_duration * 0.5)
	tween.parallel().tween_property(name_label, "modulate:a", 0.0, transition_duration * 0.5)
	tween.parallel().tween_property(name_label, "position:y", name_label.position.y - 20, transition_duration * 0.5)
	
	# Change scene when the screen is fully black
	tween.tween_callback(perform_scene_change)
	
	# Continue fading out the black background
	tween.tween_property(bg, "color:a", 0.0, transition_duration * 0.25)
	tween.tween_callback(reset_positions)
	tween.tween_callback(hide)

func perform_scene_change():
	if next_scene != "":
		get_tree().change_scene_to_file(next_scene)
	else:
		print("Warning: Next scene is not set!")

func reset_positions():
	# Reset positions for next transition
	icon.position.y += 70
	name_label.position.y += 70

func fade_in():
	show()
	var tween = create_tween()
	tween.tween_property(bg, "color:a", 1.0, transition_duration * 0.5)
	tween.tween_property(bg, "color:a", 0.0, transition_duration * 0.5)
	tween.tween_callback(hide)

func fade_out_from_black():
	show()
	bg.color = Color(0, 0, 0, 1)  # Start with a fully opaque black background
	var tween = create_tween()
	tween.tween_property(bg, "color:a", 0.0, transition_duration)
	tween.tween_callback(hide)

func set_transition_duration(duration: float):
	transition_duration = duration

func set_icon_texture(texture: Texture2D):
	icon.texture = texture

func set_name_text(text: String):
	name_label.text = text
