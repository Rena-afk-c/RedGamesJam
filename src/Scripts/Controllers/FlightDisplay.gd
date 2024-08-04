extends Control

@onready var score_label = $ScoreLabel
@onready var base = $Base
@onready var ticket_sprite = $Base/TicketSprite
@onready var ticket_label = $Base/TicketLabel
@onready var new_hs_label = $NewHSLabel
@onready var combo_label = $ComboLabel

var current_score: int = 0
var current_high_score: int = 0
var current_tickets: int = 0
var combo_count: int = 0
var last_collection_time: float = 0
var combo_timeout: float = 1.0  # 1 second timeout for combo
var high_score_shown: bool = false

func _ready():
	GameManager.currency_updated.connect(_on_currency_updated)
	GameManager.high_score_updated.connect(_on_high_score_updated)
	GameManager.ticket_collected.connect(_on_ticket_collected)
	GameManager.combo_updated.connect(_on_combo_updated)
	current_high_score = GameManager.high_score
	update_score_display(GameManager.currency_flight)
	update_ticket_display(GameManager.tickets)
	hide_effect_labels()

func _on_currency_updated(new_amount: int):
	current_score = new_amount
	update_score_display(new_amount)

func _on_high_score_updated(new_high_score: int):
	if not high_score_shown:
		current_high_score = new_high_score
		show_high_score_effect()
		high_score_shown = true

func _on_ticket_collected(new_ticket_count: int):
	current_tickets = new_ticket_count
	update_ticket_display(new_ticket_count)

func _on_combo_updated(new_combo: int):
	combo_count = new_combo
	if combo_count > 1:
		show_combo_effect()

func update_score_display(score: int):
	var tween = create_tween()
	tween.tween_property(score_label, "text", str(score), 0.5).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(score_label, "modulate", Color(1, 1, 0, 1), 0.25)
	tween.tween_property(score_label, "modulate", Color(1, 1, 1, 1), 0.25)

func update_ticket_display(tickets: int):
	ticket_label.text = str(tickets)
	
	var tween = create_tween()
	tween.tween_property(ticket_label, "modulate", Color(0, 1, 0, 1), 0.2)
	tween.tween_property(ticket_label, "modulate", Color(1, 1, 1, 1), 0.2)
	
	# Simple pulse effect for the ticket sprite
	tween.parallel().tween_property(ticket_sprite, "scale", ticket_sprite.scale * 1.1, 0.1)
	tween.tween_property(ticket_sprite, "scale", ticket_sprite.scale, 0.1)


func show_high_score_effect():
	if high_score_shown:
		return
	
	high_score_shown = true
	new_hs_label.modulate = Color(1, 0.5, 0, 0)  # Orange color, initially transparent
	new_hs_label.show()
	
	var original_position = new_hs_label.position
	var original_scale = new_hs_label.scale
	
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Fade in
	tween.tween_property(new_hs_label, "modulate:a", 1.0, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	# Scale up
	tween.tween_property(new_hs_label, "scale", original_scale * 1.2, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	# Wobble effect
	tween.tween_method(func(v): new_hs_label.rotation_degrees = sin(v * TAU) * 5, 0.0, 4.0, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	tween.chain()
	
	# Hold for a moment
	tween.tween_interval(0.7)
	
	tween.chain().set_parallel(true)
	
	# Float upwards
	tween.tween_property(new_hs_label, "position:y", original_position.y - 50, 1.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	# Fade out
	tween.tween_property(new_hs_label, "modulate:a", 0.0, 1.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	
	# Scale down
	tween.tween_property(new_hs_label, "scale", original_scale * 0.8, 1.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	
	tween.chain()
	
	# Reset
	tween.tween_callback(func():
		new_hs_label.hide()
		new_hs_label.position = original_position
		new_hs_label.scale = original_scale
		new_hs_label.rotation_degrees = 0
	)


func show_combo_effect():
	var combo_text = "x" + str(pow(2, min(combo_count - 1, 3)))  # x2, x4, x8, x16 (max)
	combo_label.text = combo_text
	
	var random_offset = Vector2(randf_range(-20, 20), randf_range(-20, 20))
	var original_position = combo_label.position
	
	combo_label.show()
	var tween = create_tween()
	
	# Random position and rotation
	tween.tween_property(combo_label, "position", original_position + random_offset, 0.1)
	tween.parallel().tween_property(combo_label, "rotation", randf_range(-0.2, 0.2), 0.1)
	
	# Shake effect
	for i in range(5):
		var shake_offset = Vector2(randf_range(-5, 5), randf_range(-5, 5))
		tween.tween_property(combo_label, "position", original_position + random_offset + shake_offset, 0.05)
	
	# Fade out
	tween.tween_property(combo_label, "modulate:a", 0.0, 0.3)
	tween.tween_callback(combo_label.hide)
	
	# Reset position and rotation
	tween.tween_callback(func():
		combo_label.position = original_position
		combo_label.rotation = 0
		combo_label.modulate.a = 1.0
	)

func hide_effect_labels():
	new_hs_label.hide()
	combo_label.hide()
