extends CanvasLayer

@onready var bg = $BG
@onready var icon = $Icon
@onready var name_label = $NameLabel

@export var transition_duration: float = 1.0

var next_scene: String = ""

func _ready():
	# Ensure all elements are invisible at start
	bg.color = Color(0, 0, 0, 1)  # Fully opaque black background
	icon.modulate.a = 0
	name_label.modulate.a = 0
	
	# Set initial positions
	icon.position.y += 50
	name_label.position.y += 50
	
	# Hide the entire transition layer initially
	hide()

func change_scene(target_scene: String):
	next_scene = target_scene
	show()  # Show the transition layer
	setup_transition_animation()

func setup_transition_animation():
	var tween = create_tween()
	
	# Fade in and animate icon and name label
	tween.parallel().tween_property(icon, "modulate:a", 1.0, transition_duration * 0.5)
	tween.parallel().tween_property(icon, "position:y", icon.position.y - 50, transition_duration * 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.parallel().tween_property(name_label, "modulate:a", 1.0, transition_duration * 0.5)
	tween.parallel().tween_property(name_label, "position:y", name_label.position.y - 50, transition_duration * 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	
	# Pause
	tween.tween_interval(transition_duration)
	
	# Fade out
	tween.parallel().tween_property(icon, "modulate:a", 0.0, transition_duration * 0.5)
	tween.parallel().tween_property(icon, "position:y", icon.position.y - 20, transition_duration * 0.5)
	tween.parallel().tween_property(name_label, "modulate:a", 0.0, transition_duration * 0.5)
	tween.parallel().tween_property(name_label, "position:y", name_label.position.y - 20, transition_duration * 0.5)
	
	# Change scene
	tween.tween_callback(perform_scene_change)

func perform_scene_change():
	if next_scene != "":
		get_tree().change_scene_to_file(next_scene)
	else:
		print("Warning: Next scene is not set!")
	
	# Reset positions for next transition
	icon.position.y += 70
	name_label.position.y += 70
	
	# Hide the transition layer
	hide()

func set_transition_duration(duration: float):
	transition_duration = duration

func set_icon_texture(texture: Texture2D):
	icon.texture = texture

func set_name_text(text: String):
	name_label.text = text
