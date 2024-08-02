extends Path2D

@export var speed = 100  # Pixels per second

@onready var path_follow = $PathFollow2D

func _physics_process(delta):
	# Move all luggage along the path
	for child in path_follow.get_children():
		if child.is_in_group("luggage"):
			child.offset += speed * delta
			
			# If luggage completes a full loop, remove it
			if child.offset >= curve.get_baked_length():
				child.queue_free()
