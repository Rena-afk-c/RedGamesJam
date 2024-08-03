extends Control

@onready var suit_case_root = $SuitCaseRoot
@onready var boundary_right_2 = $CloudRoot/BoundaryRight2
@onready var boundary_right = $CloudRoot/BoundaryRight
@onready var cloud_root = $CloudRoot
@onready var boundary_left_case = $SuitCaseRoot/BoundaryLeft
@onready var boundary_right_case = $SuitCaseRoot/BoundaryRight

var suitcase_speeds = []
var suitcase_directions = []
var suitcase_base_speed = 50
var suitcase_speed_variation = 30
var screen_size: Vector2
var cloud_speed = 20  # Adjust this for faster/slower cloud movement
const CLOUD_INITIAL_SCALE = 0.142



func _ready():
	screen_size = get_viewport_rect().size
	setup_suitcases()
	setup_clouds()

func _process(delta):
	move_suitcases(delta)
	move_clouds(delta)

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		check_cloud_tap(event.position)

func setup_suitcases():
	var suitcase_count = suit_case_root.get_child_count()
	
	for i in range(suitcase_count):
		var suitcase = suit_case_root.get_child(i)
		if not suitcase is Sprite2D:
			continue
		
		# Set initial position (all suitcases start at the same location)
		suitcase.position = boundary_left_case.position
		
		# Assign a random speed to each suitcase
		var speed = suitcase_base_speed + randf_range(-suitcase_speed_variation, suitcase_speed_variation)
		suitcase_speeds.append(speed)
		
		# Randomly assign initial direction (1 for right, -1 for left)
		suitcase_directions.append(1 if randf() > 0.5 else -1)


func move_suitcases(delta):
	var left_boundary = boundary_left_case.position.x
	var right_boundary = boundary_right_case.position.x
	
	for i in range(suit_case_root.get_child_count()):
		var suitcase = suit_case_root.get_child(i)
		if not suitcase is Sprite2D:
			continue
		
		var speed = suitcase_speeds[i]
		var direction = suitcase_directions[i]
		
		suitcase.position.x += speed * direction * delta
		
		# Check boundaries and reverse direction if needed
		if suitcase.position.x > right_boundary:
			suitcase.position.x = right_boundary
			suitcase_directions[i] = -1
		elif suitcase.position.x < left_boundary:
			suitcase.position.x = left_boundary
			suitcase_directions[i] = 1
		
		# Add some vertical oscillation for a bouncing effect
		suitcase.position.y += sin(Time.get_ticks_msec() * 0.005 + suitcase.position.x * 0.1) * delta * 2

func setup_clouds():
	for cloud in cloud_root.get_children():
		if cloud is Sprite2D:
			cloud.position.x = randf_range(0, boundary_right.position.x)
			cloud.position.y = randf_range(0, screen_size.y)
			cloud.scale = Vector2(CLOUD_INITIAL_SCALE, CLOUD_INITIAL_SCALE)

func move_clouds(delta):
	var left_boundary = 0
	var right_boundary = boundary_right.position.x
	
	for cloud in cloud_root.get_children():
		if cloud is Sprite2D:
			cloud.position.x += cloud_speed * delta
			cloud.position.y += sin(Time.get_ticks_msec() * 0.001 + cloud.position.x * 0.1) * delta * 5
			
			if cloud.position.x > right_boundary:
				cloud.position.x = left_boundary - cloud.texture.get_width() * CLOUD_INITIAL_SCALE
			elif cloud.position.x < left_boundary - cloud.texture.get_width() * CLOUD_INITIAL_SCALE:
				cloud.position.x = right_boundary

func check_cloud_tap(tap_position):
	for cloud in cloud_root.get_children():
		if cloud is Sprite2D and cloud.get_rect().has_point(cloud.to_local(tap_position)):
			animate_cloud_tap(cloud)

func animate_cloud_tap(cloud):
	var tween = create_tween()
	var scale_increase = 0.03  # This will make the cloud about 21% larger at peak
	
	# Scale up
	tween.tween_property(cloud, "scale", Vector2(CLOUD_INITIAL_SCALE + scale_increase, CLOUD_INITIAL_SCALE + scale_increase), 0.1)
	# Scale back down
	tween.tween_property(cloud, "scale", Vector2(CLOUD_INITIAL_SCALE, CLOUD_INITIAL_SCALE), 0.1)
	# Fade out slightly
	tween.tween_property(cloud, "modulate:a", 0.7, 0.1)
	# Fade back in
	tween.tween_property(cloud, "modulate:a", 1, 0.1)
