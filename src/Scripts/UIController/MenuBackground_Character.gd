extends Node2D

@onready var bam = $Bam
@onready var biggie = $Biggie
@onready var tappy = $Tappy
@onready var ogu = $Ogu
@onready var character_boundary_left = $CharacterBoundaryLeft
@onready var character_boundary_right = $CharacterBoundaryRight

var npcs = []
var npc_speeds = []
var npc_directions = []
var base_speed = 50
var speed_variation = 30

func _ready():
	npcs = [bam, biggie, tappy, ogu]
	setup_npcs()

func _process(delta):
	move_npcs(delta)

func setup_npcs():
	for npc in npcs:
		# Set initial position
		npc.position.x = randf_range(character_boundary_left.position.x, character_boundary_right.position.x)
		
		# Assign random speed
		var speed = base_speed + randf_range(-speed_variation, speed_variation)
		npc_speeds.append(speed)
		
		# Assign random direction (1 for right, -1 for left)
		npc_directions.append(1 if randf() > 0.5 else -1)
		
		# Ensure the walk animation is playing
		if npc.has_method("play"):
			npc.play("default")

func move_npcs(delta):
	var left_boundary = character_boundary_left.position.x
	var right_boundary = character_boundary_right.position.x
	
	for i in range(npcs.size()):
		var npc = npcs[i]
		var speed = npc_speeds[i]
		var direction = npc_directions[i]
		
		npc.position.x += speed * direction * delta
		
		# Check boundaries and reverse direction if needed
		if npc.position.x > right_boundary:
			npc.position.x = right_boundary
			npc_directions[i] = -1
			npc.scale.x = abs(npc.scale.x)  # Face left (no flip)
		elif npc.position.x < left_boundary:
			npc.position.x = left_boundary
			npc_directions[i] = 1
			npc.scale.x = -abs(npc.scale.x)  # Face right (flip)
		
		# Ensure the sprite is always facing the direction of movement
		if direction > 0:  # Moving right
			npc.scale.x = -abs(npc.scale.x)  # Flip horizontally
		else:  # Moving left
			npc.scale.x = abs(npc.scale.x)  # No flip

