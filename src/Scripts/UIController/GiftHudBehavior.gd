extends Control

@onready var t_daily_gift_btn = $GiftPanel/TDailyGiftBtn
@onready var t_claim_btn = $GiftHud/TClaimBtn
@onready var claim_btn_base = $GiftHud/ClaimBtnBase
@onready var body = $GiftHud/Body
@onready var sprite_2d = $GiftHud/Body/Sprite2D
@onready var timer_label = $GiftHud/Body/TimerLabel
@onready var gift_hud = $GiftHud

var claim_timer: Timer
var can_claim: bool = true
const CLAIM_COOLDOWN: int = 86400  # 24 hours in seconds

func _ready():
	# Hide gift HUD by default
	gift_hud.hide()
	
	# Set up claim timer
	claim_timer = Timer.new()
	claim_timer.one_shot = true
	claim_timer.connect("timeout", _on_claim_timer_timeout)
	add_child(claim_timer)
	
	# Start gift sprite animation
	_start_gift_animation()

func _process(delta):
	if not can_claim:
		_update_timer_label()

func _on_t_daily_gift_btn_pressed():
	gift_hud.show()

func _on_t_claim_btn_pressed():
	if can_claim:
		print("Gift claimed! Add your reward logic here.")
		_start_claim_cooldown()
	else:
		print("You can't claim a gift yet. Please wait for the cooldown to finish.")

func _start_claim_cooldown():
	can_claim = false
	claim_timer.start(CLAIM_COOLDOWN)
	t_claim_btn.disabled = true

func _on_claim_timer_timeout():
	can_claim = true
	t_claim_btn.disabled = false
	timer_label.text = "Claim Now!"

func _update_timer_label():
	var time_left = claim_timer.time_left
	var hours = floor(time_left / 3600)
	var minutes = floor((time_left % 3600) / 60)
	var seconds = floor(time_left % 60)
	timer_label.text = "%02d:%02d:%02d" % [hours, minutes, seconds]

func _start_gift_animation():
	var tween = create_tween().set_loops()
	tween.tween_property(sprite_2d, "scale", Vector2(1.1, 1.1), 1.0).set_trans(Tween.TRANS_SINE)
	tween.tween_property(sprite_2d, "scale", Vector2(1.0, 1.0), 1.0).set_trans(Tween.TRANS_SINE)

	var rotation_tween = create_tween().set_loops()
	rotation_tween.tween_property(sprite_2d, "rotation_degrees", 5, 2.0).set_trans(Tween.TRANS_SINE)
	rotation_tween.tween_property(sprite_2d, "rotation_degrees", -5, 2.0).set_trans(Tween.TRANS_SINE)
