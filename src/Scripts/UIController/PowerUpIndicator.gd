extends Control

@onready var sprite1 = $Control1/Sprite1
@onready var progressBar1 = $Control1/ProgressBar1
@onready var sprite2 = $Control2/Sprite2
@onready var progressBar2 = $Control2/ProgressBar2
@onready var sprite3 = $Control3/Sprite3
@onready var progressBar3 = $Control3/ProgressBar3
@onready var sprite4 = $Control4/Sprite4
@onready var progressBar4 = $Control4/ProgressBar4

var coolDownDuration1 = 5.0
var coolDownDuration2 = 5.0
var coolDownDuration3 = 5.0
var coolDownDuration4 = 5.0

var coolDownTimer1 = 0.0
var coolDownTimer2 = 0.0
var coolDownTimer3 = 0.0
var coolDownTimer4 = 0.0

var onCooldown1 = false
var onCooldown2 = false
var onCooldown3 = false
var onCooldown4 = false

func _ready():
	# Initialize progress bars to full value
	progressBar1.value = 100
	progressBar2.value = 100
	progressBar3.value = 100
	progressBar4.value = 100

	# Optionally, hide sprites at the start if they should be hidden initially
	sprite1.hide()
	sprite2.hide()
	sprite3.hide()
	sprite4.hide()

func _physics_process(delta):
	# Update cooldowns and progress bars
	update_cooldown(progressBar1, coolDownTimer1, coolDownDuration1, onCooldown1, sprite1, delta)
	update_cooldown(progressBar2, coolDownTimer2, coolDownDuration2, onCooldown2, sprite2, delta)
	update_cooldown(progressBar3, coolDownTimer3, coolDownDuration3, onCooldown3, sprite3, delta)
	update_cooldown(progressBar4, coolDownTimer4, coolDownDuration4, onCooldown4, sprite4, delta)

func update_cooldown(progressBar: ProgressBar, timer: float, duration: float, on_cooldown: bool, sprite: Sprite2D, delta: float):
	if on_cooldown:
		timer -= delta
		progressBar.value = max(0, (timer / duration) * 100) # Update progress bar value
		if timer <= 0:
			timer = 0
			on_cooldown = false
			sprite.hide() # Hide sprite when cooldown is complete
			progressBar.value = 0
	else:
		progressBar.value = 100 # Reset progress bar if not on cooldown

func start_cooldown(cooldown_id: int):
	match cooldown_id:
		1:
			if not onCooldown1:
				coolDownTimer1 = coolDownDuration1
				onCooldown1 = true
				sprite1.show() # Show sprite when cooldown starts
		2:
			if not onCooldown2:
				coolDownTimer2 = coolDownDuration2
				onCooldown2 = true
				sprite2.show() # Show sprite when cooldown starts
		3:
			if not onCooldown3:
				coolDownTimer3 = coolDownDuration3
				onCooldown3 = true
				sprite3.show() # Show sprite when cooldown starts
		4:
			if not onCooldown4:
				coolDownTimer4 = coolDownDuration4
				onCooldown4 = true
				sprite4.show() # Show sprite when cooldown starts
