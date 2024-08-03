extends Camera2D

var shake_strength: float = 0.0
var shake_decay: float = 5.0
var noise := FastNoiseLite.new()
var noise_y := 0.0

func _ready():
	noise.seed = randi()
	noise.frequency = 0.5
	set_process(true)

func _process(delta: float) -> void:
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength, 0.0, shake_decay * delta)
		
		var shake_offset := Vector2.ZERO
		noise_y += 1.0
		shake_offset.x = noise.get_noise_2d(noise.seed, noise_y) * shake_strength
		shake_offset.y = noise.get_noise_2d(noise.seed * 2, noise_y) * shake_strength
		
		offset = shake_offset
	else:
		offset = Vector2.ZERO

func shake(strength: float, duration: float = 0.2) -> void:
	shake_strength = strength
	shake_decay = 1.0 / duration
	noise_y = 0.0
