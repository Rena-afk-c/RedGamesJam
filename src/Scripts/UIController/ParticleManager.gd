extends Node

const CLICK_SPRAY_SCENE_PATH = "res://src/ParticleEffects/click_spray.tscn"
const CONFETTI_SCENE_PATH = "res://src/ParticleEffects/confetti.tscn"
const EXPLODING_PARTICLE_SCENE_PATH = "res://src/ParticleEffects/exploding_particle.tscn"
const RAINING_COIN_SCENE_PATH = "res://src/ParticleEffects/raining_coin.tscn"

func create_click_spray_particle(position: Vector2):
	var particle_scene = preload(CLICK_SPRAY_SCENE_PATH)
	var particle_instance = particle_scene.instantiate()
	
	particle_instance.position = position
	
	get_tree().current_scene.add_child(particle_instance)
	
	particle_instance.emitting = true
	
	await get_tree().create_timer(1.5).timeout
	particle_instance.queue_free()

func create_confetti_particle():
	var particle_scene = preload(CONFETTI_SCENE_PATH)
	var particle_instance = particle_scene.instantiate()
	
	get_tree().current_scene.add_child(particle_instance)
	
	for child in particle_instance.get_children():
		if child is CPUParticles2D:
			child.emitting = true
	
	# Optionally, set a timer to remove the particle effect after some time
	await get_tree().create_timer(4).timeout
	particle_instance.queue_free()
	
func create_exploding_particle():
	var particle_scene = preload(EXPLODING_PARTICLE_SCENE_PATH)
	var particle_instance = particle_scene.instantiate()
	
	get_tree().current_scene.add_child(particle_instance)
	
	particle_instance.emitting = true
	
	await get_tree().create_timer(1.5).timeout
	particle_instance.queue_free()

func create_raining_coin_particle():
	var particle_scene = preload(RAINING_COIN_SCENE_PATH)
	var particle_instance = particle_scene.instantiate()
	
	get_tree().current_scene.add_child(particle_instance)
	
	particle_instance.emitting = true
	
	await get_tree().create_timer(2.0).timeout
	particle_instance.queue_free()
