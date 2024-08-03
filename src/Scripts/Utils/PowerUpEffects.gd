extends Node

signal time_slow_activated(slow_factor: float)
signal time_slow_deactivated
signal point_frenzy_activated(multiplier: float)
signal point_frenzy_deactivated
signal luggage_free_for_all_activated
signal luggage_free_for_all_deactivated

@export var time_slow_factor: float = 0.5
@export var point_frenzy_multiplier: float = 2.0
@export var luggage_automata_radius: float = 100.0

var active_powerups: Dictionary = {
	PowerUpManager.PowerUpType.LUGGAGE_AUTOMATA: false,
	PowerUpManager.PowerUpType.TIME_SLOW: false,
	PowerUpManager.PowerUpType.POINT_FRENZY: false,
	PowerUpManager.PowerUpType.LUGGAGE_FREE_FOR_ALL: false
}

func activate_powerup(powerup_type: PowerUpManager.PowerUpType):
	active_powerups[powerup_type] = true
	match powerup_type:
		PowerUpManager.PowerUpType.LUGGAGE_AUTOMATA:
			print("Luggage Automata activated")
		PowerUpManager.PowerUpType.TIME_SLOW:
			emit_signal("time_slow_activated", time_slow_factor)
			print("Time Slow activated")
		PowerUpManager.PowerUpType.POINT_FRENZY:
			emit_signal("point_frenzy_activated", point_frenzy_multiplier)
			print("Point Frenzy activated")
		PowerUpManager.PowerUpType.LUGGAGE_FREE_FOR_ALL:
			emit_signal("luggage_free_for_all_activated")
			print("Luggage Free-For-All activated")

func deactivate_powerup(powerup_type: PowerUpManager.PowerUpType):
	active_powerups[powerup_type] = false
	match powerup_type:
		PowerUpManager.PowerUpType.LUGGAGE_AUTOMATA:
			print("Luggage Automata deactivated")
		PowerUpManager.PowerUpType.TIME_SLOW:
			emit_signal("time_slow_deactivated")
			print("Time Slow deactivated")
		PowerUpManager.PowerUpType.POINT_FRENZY:
			emit_signal("point_frenzy_deactivated")
			print("Point Frenzy deactivated")
		PowerUpManager.PowerUpType.LUGGAGE_FREE_FOR_ALL:
			emit_signal("luggage_free_for_all_deactivated")
			print("Luggage Free-For-All deactivated")

func _physics_process(delta):
	if active_powerups[PowerUpManager.PowerUpType.LUGGAGE_AUTOMATA]:
		auto_collect_luggage()

func auto_collect_luggage():
	var luggage_items = get_tree().get_nodes_in_group("luggage")
	var players = get_tree().get_nodes_in_group("player")
	
	for player in players:
		for luggage in luggage_items:
			if luggage.global_position.distance_to(player.global_position) <= luggage_automata_radius:
				if active_powerups[PowerUpManager.PowerUpType.LUGGAGE_FREE_FOR_ALL] or luggage.luggage_type == player.character_type:
					# Collect the luggage
					GameManager.collect_luggage()
					luggage.queue_free()
					print("Auto-collected luggage for ", GameManager.Characters.keys()[player.character_type])
					break  # Move to the next player
