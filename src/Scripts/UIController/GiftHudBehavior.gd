extends Control

@onready var t_daily_gift_btn = $GiftPanel/TDailyGiftBtn
@onready var t_claim_btn = $GiftHud/TClaimBtn
@onready var timer_label = $GiftHud/Body/TimerLabel
@onready var gift_hud = $GiftHud
@onready var sprite_2d = $GiftHud/Body/Sprite2D

var claim_timer: Timer
var can_claim: bool = true
const CLAIM_COOLDOWN: int = 86400  # 24 hours in seconds
const SPRITE_DEFAULT_SCALE: Vector2 = Vector2(0.049, 0.049)

var is_hud_visible: bool = false
var is_animating: bool = false
var hud_center_position: Vector2

func _ready():
	# Initialize gift HUD
	hud_center_position = gift_hud.position
	gift_hud.modulate.a = 0  # Start fully transparent
	gift_hud.scale = Vector2.ZERO  # Start with zero scale
	gift_hud.show()  # Make visible but scaled to zero
	
	# Set up claim timer
	claim_timer = Timer.new()
	claim_timer.one_shot = true
	claim_timer.timeout.connect(_on_claim_timer_timeout)
	add_child(claim_timer)
	
	# Start gift sprite animation
	_start_gift_animation()
	
	# Connect touch screen button signals only if not already connected
	if not t_daily_gift_btn.pressed.is_connected(_on_t_daily_gift_btn_pressed):
		t_daily_gift_btn.pressed.connect(_on_t_daily_gift_btn_pressed)
	if not t_claim_btn.pressed.is_connected(_on_t_claim_btn_pressed):
		t_claim_btn.pressed.connect(_on_t_claim_btn_pressed)

func _process(delta):
	if not can_claim:
		_update_timer_label()

func _on_t_daily_gift_btn_pressed():
	AudioManager.button_click()
	if not is_animating:
		if is_hud_visible:
			_hide_gift_hud()
		else:
			_show_gift_hud()

func _show_gift_hud():
	is_animating = true
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(gift_hud, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(gift_hud, "modulate:a", 1, 0.3)
	tween.chain().tween_callback(func():
		is_hud_visible = true
		is_animating = false
		_update_timer_label()
	)

func _hide_gift_hud():
	is_animating = true
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(gift_hud, "scale", Vector2.ZERO, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_property(gift_hud, "modulate:a", 0, 0.3)
	tween.chain().tween_callback(func():
		is_hud_visible = false
		is_animating = false
	)

# The rest of the functions remain the same

func _update_timer_label():
	if can_claim:
		timer_label.text = "Available Now!"
	else:
		var time_left = int(claim_timer.time_left)
		if time_left >= 3600:
			var hours = time_left / 3600
			timer_label.text = "   %d hour%s" % [hours, "s" if hours > 1 else ""]
		elif time_left >= 60:
			var minutes = time_left / 60
			timer_label.text = "   %d minute%s" % [minutes, "s" if minutes > 1 else ""]
		else:
			timer_label.text = "   %d second%s" % [time_left, "s" if time_left > 1 else ""]

func _on_t_claim_btn_pressed():
	AudioManager.button_click()
	if can_claim:
		collect_daily_reward()
		_start_claim_cooldown()
	else:
		AudioManager.incorrect_option_sfx()
		print("You can't claim a gift yet. Please wait for the cooldown to finish.")

func collect_daily_reward():
	ParticleManager.create_confetti_particle()
	print("Daily reward collected!")
	
	# Add your reward logic here

func _start_claim_cooldown():
	can_claim = false
	claim_timer.start(CLAIM_COOLDOWN)
	t_claim_btn.modulate.a = 0.5  # Make the button semi-transparent

func _on_claim_timer_timeout():
	can_claim = true
	t_claim_btn.modulate.a = 1.0  # Restore full opacity
	_update_timer_label()  # Update the label immediately when the timer expires

func _start_gift_animation():
	var float_height: float = 5.0
	var float_duration: float = 4.0
	
	# Store initial position and rotation
	var initial_position = sprite_2d.position
	var initial_rotation = sprite_2d.rotation_degrees
	
	# Create a single tween for both position and rotation
	var tween = create_tween()
	tween.set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	# First half of the animation
	tween.tween_property(sprite_2d, "position:y", initial_position.y - float_height, float_duration * 0.5)
	tween.parallel().tween_property(sprite_2d, "rotation_degrees", -5, float_duration * 0.5)
	
	# Second half of the animation
	tween.tween_property(sprite_2d, "position:y", initial_position.y, float_duration * 0.5)
	tween.parallel().tween_property(sprite_2d, "rotation_degrees", initial_rotation, float_duration * 0.5)
