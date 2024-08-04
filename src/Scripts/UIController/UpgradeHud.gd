extends Control

@onready var upgrade_la: TouchScreenButton = $Root/UpgradeLA
@onready var upgrade_ts: TouchScreenButton = $Root/UpgradeTS
@onready var upgrade_pf: TouchScreenButton = $Root/UpgradePF
@onready var upgrade_ffa: TouchScreenButton = $Root/UpgradeFFA
@onready var close_btn: TouchScreenButton = $Root/CloseBtn
@onready var root = $Root

var tween: Tween

const UPGRADE_BUTTON_SCALE = Vector2(0.021, 0.021)
const CLOSE_BUTTON_SCALE = Vector2(0.044, 0.044)
const POP_SCALE_FACTOR = 1.2

func _ready():
	hide()
	root.scale = Vector2.ZERO
	
	for button in [upgrade_la, upgrade_ts, upgrade_pf, upgrade_ffa]:
		button.scale = UPGRADE_BUTTON_SCALE
	close_btn.scale = CLOSE_BUTTON_SCALE
	
	#upgrade_la.pressed.connect(_on_upgrade_la_pressed)
	#upgrade_ts.pressed.connect(_on_upgrade_ts_pressed)
	#upgrade_pf.pressed.connect(_on_upgrade_pf_pressed)
	#upgrade_ffa.pressed.connect(_on_upgrade_ffa_pressed)
	close_btn.pressed.connect(_on_close_btn_pressed)

func utilize():
	show()
	_animate_menu(true)

func close():
	_animate_menu(false)

func _animate_menu(open: bool):
	if tween:
		tween.kill()
	
	tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN_OUT)
	
	if open:
		tween.tween_property(root, "scale", Vector2.ONE, 0.3)
	else:
		tween.tween_property(root, "scale", Vector2.ZERO, 0.3)
		tween.tween_callback(hide)

func _button_pop_effect(button: TouchScreenButton):
	var original_scale = UPGRADE_BUTTON_SCALE if button != close_btn else CLOSE_BUTTON_SCALE
	var pop_scale = original_scale * POP_SCALE_FACTOR
	
	var pop_tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	pop_tween.tween_property(button, "scale", pop_scale, 0.1)
	pop_tween.tween_property(button, "scale", original_scale, 0.1)

func _on_upgrade_la_pressed():
	AudioManager.button_click()
	_button_pop_effect(upgrade_la)
	# Add your upgrade logic here

func _on_upgrade_ts_pressed():
	AudioManager.button_click()
	_button_pop_effect(upgrade_ts)
	# Add your upgrade logic here

func _on_upgrade_pf_pressed():
	AudioManager.button_click()
	_button_pop_effect(upgrade_pf)
	# Add your upgrade logic here

func _on_upgrade_ffa_pressed():
	AudioManager.button_click()
	_button_pop_effect(upgrade_ffa)
	# Add your upgrade logic here

func _on_close_btn_pressed():
	AudioManager.button_click()
	_button_pop_effect(close_btn)
	close()
