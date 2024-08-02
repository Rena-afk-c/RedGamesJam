extends CanvasModulate

enum WeatherState { DAY, MID, NIGHT }

@export var day_color: Color = Color(1.0, 1.0, 1.0, 1.0)
@export var mid_color: Color = Color(0.8, 0.8, 0.9, 1.0)
@export var night_color: Color = Color(0.2, 0.2, 0.4, 1.0)
@export var transition_duration: float = 10.0  # Duration in seconds
@export var cycle_duration: float = 60.0 

var current_state: WeatherState = WeatherState.DAY
var transition_timer: float = 0.0
var cycle_timer: float = 0.0

func _ready():
	color = day_color  

func _process(delta):
	cycle_timer += delta
	if cycle_timer >= cycle_duration:
		cycle_timer = 0.0
		current_state = WeatherState.DAY
	
	var target_color: Color
	var progress: float = cycle_timer / cycle_duration
	
	if progress < 1.0 / 3.0:
		target_color = day_color.lerp(mid_color, smoothstep(0.0, 1.0 / 3.0, progress) * 3.0)
	elif progress < 2.0 / 3.0:
		target_color = mid_color.lerp(night_color, smoothstep(1.0 / 3.0, 2.0 / 3.0, progress) * 3.0 - 1.0)
	else:
		target_color = night_color.lerp(day_color, smoothstep(2.0 / 3.0, 1.0, progress) * 3.0 - 2.0)
	
	color = color.lerp(target_color, delta / transition_duration)

func smoothstep(edge0: float, edge1: float, x: float) -> float:
	var t = clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0)
	return t * t * (3.0 - 2.0 * t)
