@tool
extends AnimatedSprite2D
const AnimationFunction = preload("res://addons/supersprite2d/Animation_Function.gd")
@export var function_calls: Array[AnimationFunction] = []

var _current_animation: String = ""
var _loop_counters: Dictionary = {}

func _ready():
	animation_finished.connect(_on_animation_finished)
	frame_changed.connect(_on_frame_changed)

func _on_animation_finished():
	_current_animation = ""
	_loop_counters.clear()

func _on_frame_changed():
	var current_frame = get_frame()
	_check_and_call_functions(current_frame)

func play(anim: StringName = &"", custom_speed: float = 1.0, from_end: bool = false) -> void:
	super.play(anim, custom_speed, from_end)
	_current_animation = anim
	_loop_counters.clear()

func _check_and_call_functions(frame: int):
	for func_call in function_calls:
		if func_call.animation_name == _current_animation and func_call.frame == frame:
			if not func_call.loop or _should_call_looped_function(func_call):
				_call_function(func_call)

func _should_call_looped_function(func_call: AnimationFunction) -> bool:
	if not _loop_counters.has(func_call):
		_loop_counters[func_call] = 0
	
	_loop_counters[func_call] += 1
	if _loop_counters[func_call] % func_call.loop_interval == 0:
		return true
	return false

func _call_function(func_call: AnimationFunction):
	var target = _get_target(func_call.target_type)
	if target and (target.has_method(func_call.function_name) or func_call.function_name in ["queue_free", "free"]):
		if func_call.function_name == "queue_free":
			target.queue_free()
		elif func_call.function_name == "free":
			target.free()
		else:
			target.callv(func_call.function_name, func_call.arguments)
	else:
		push_warning("Function '%s' not found in target of AnimatedSpriteFunctionCaller." % func_call.function_name)

func _get_target(target_type: AnimationFunction.TargetType):
	match target_type:
		AnimationFunction.TargetType.PARENT:
			return get_parent()
		AnimationFunction.TargetType.SELF:
			return self
		AnimationFunction.TargetType.SCENE:
			return get_tree().current_scene
	return null

