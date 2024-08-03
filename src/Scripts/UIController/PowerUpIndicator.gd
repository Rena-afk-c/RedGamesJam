extends Control

@export var tappy_progress_bar: TextureProgressBar
@export var bam_progress_bar: TextureProgressBar
@export var biggie_progress_bar: TextureProgressBar
@export var ogu_progress_bar: TextureProgressBar

@onready var bam_sprite = $BamProgressBar/sprite
@onready var biggie_sprite = $BiggieProgressBar/sprite
@onready var tappy_sprite = $TappyProgressBar/sprite
@onready var ogu_sprite = $OguProgressBar/sprite

var active_tween: Tween
const SPRITE_SCALE = Vector2(0.02, 0.02)
const INACTIVE_MODULATE = Color(1, 1, 1, 0.5)  # Adjust alpha for inactive sprite visibility

func _ready():
	PowerUpManager.connect("powerup_activated", Callable(self, "_on_powerup_activated"))
	PowerUpManager.connect("powerup_deactivated", Callable(self, "_on_powerup_deactivated"))
	
	for progress_bar in [tappy_progress_bar, bam_progress_bar, biggie_progress_bar, ogu_progress_bar]:
		if progress_bar:
			progress_bar.value = 0
			progress_bar.hide()  # Hide progress bars initially
	
	for sprite in [bam_sprite, biggie_sprite, tappy_sprite, ogu_sprite]:
		if sprite:
			sprite.modulate = Color(1, 1, 1, 0)
			sprite.scale = SPRITE_SCALE

func _process(delta):
	update_progress_bars()

func update_progress_bars():
	var active_powerup = PowerUpManager.get_active_powerup_type()
	var time_left = PowerUpManager.get_active_powerup_time_left()
	
	update_single_powerup(tappy_progress_bar, tappy_sprite, PowerUpManager.PowerUpType.LUGGAGE_AUTOMATA, active_powerup, time_left, PowerUpManager.get_powerup_duration(PowerUpManager.CharacterType.TAPPY))
	update_single_powerup(bam_progress_bar, bam_sprite, PowerUpManager.PowerUpType.TIME_SLOW, active_powerup, time_left, PowerUpManager.get_powerup_duration(PowerUpManager.CharacterType.BAM))
	update_single_powerup(biggie_progress_bar, biggie_sprite, PowerUpManager.PowerUpType.POINT_FRENZY, active_powerup, time_left, PowerUpManager.get_powerup_duration(PowerUpManager.CharacterType.BIGGIE))
	update_single_powerup(ogu_progress_bar, ogu_sprite, PowerUpManager.PowerUpType.LUGGAGE_FREE_FOR_ALL, active_powerup, time_left, PowerUpManager.get_powerup_duration(PowerUpManager.CharacterType.OGU))

func update_single_powerup(progress_bar: TextureProgressBar, sprite: Sprite2D, powerup_type: int, active_powerup: int, time_left: float, total_duration: float):
	if progress_bar and sprite:
		if active_powerup != PowerUpManager.PowerUpType.NONE:
			show_sprite(sprite)
			progress_bar.show()  # Show progress bar when a powerup is active
			if powerup_type == active_powerup:
				sprite.modulate = Color(1, 1, 1, 1)
				var progress = (time_left / total_duration) * 100
				tween_progress_bar(progress_bar, progress)
			else:
				sprite.modulate = INACTIVE_MODULATE
				tween_progress_bar(progress_bar, 100)  # Keep inactive bars full
		else:
			hide_sprite(sprite)
			progress_bar.hide()  # Hide progress bar when no powerup is active
		
		progress_bar.value = progress_bar.value

func tween_progress_bar(progress_bar: TextureProgressBar, target_value: float):
	if progress_bar:
		if active_tween and active_tween.is_valid():
			active_tween.kill()
		progress_bar.value = target_value  # Set value immediately
		active_tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
		active_tween.tween_property(progress_bar, "value", target_value, 0.1)  # Shorter tween time

func show_sprite(sprite: Sprite2D):
	if sprite and sprite.modulate.a == 0:
		var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(sprite, "modulate:a", 1.0, 0.3)

func hide_sprite(sprite: Sprite2D):
	if sprite and sprite.modulate.a > 0:
		var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		tween.tween_property(sprite, "modulate:a", 0.0, 0.3)

func _on_powerup_activated(powerup_type: int):
	update_progress_bars()

func _on_powerup_deactivated():
	update_progress_bars()
