extends Node

# Enum for character types
enum CharacterType {
	TAPPY,
	BAM,
	BIGGIE,
	OGU
}



# Enum for powerup types
enum PowerUpType {
	NONE,
	LUGGAGE_AUTOMATA,
	TIME_SLOW,
	POINT_FRENZY,
	LUGGAGE_FREE_FOR_ALL
}

# Dictionary to store powerup data
var powerups = {
	CharacterType.TAPPY: {
		"type": PowerUpType.LUGGAGE_AUTOMATA,
		"name": "Luggage Automata",
		"duration": 10.0
	},
	CharacterType.BAM: {
		"type": PowerUpType.TIME_SLOW,
		"name": "Time Slow",
		"duration": 15.0
	},
	CharacterType.BIGGIE: {
		"type": PowerUpType.POINT_FRENZY,
		"name": "Point Frenzy",
		"duration": 20.0
	},
	CharacterType.OGU: {
		"type": PowerUpType.LUGGAGE_FREE_FOR_ALL,
		"name": "Luggage Free-For-All",
		"duration": 12.0
	}
}

var upgrade_levels = {
	PowerUpType.LUGGAGE_AUTOMATA: 1,
	PowerUpType.TIME_SLOW: 1,
	PowerUpType.POINT_FRENZY: 1,
	PowerUpType.LUGGAGE_FREE_FOR_ALL: 1
}

var active_powerup: PowerUpType = PowerUpType.NONE
var active_powerup_time_left: float = 0.0

signal powerup_activated(powerup_type, duration)
signal powerup_deactivated(powerup_type)

func get_powerup_data(character_type: CharacterType) -> Dictionary:
	return powerups[character_type]

func get_powerup_duration(character_type: CharacterType) -> float:
	var base_duration = powerups[character_type]["duration"]
	var upgrade_level = upgrade_levels[powerups[character_type]["type"]]
	return base_duration * (1 + (upgrade_level - 1) * 0.1)

func upgrade_powerup(powerup_type: PowerUpType) -> void:
	if upgrade_levels[powerup_type] < 10:  
		upgrade_levels[powerup_type] += 1


func is_powerup_active(powerup_type: PowerUpType) -> bool:
	return active_powerup == powerup_type

func get_upgrade_level(powerup_type: PowerUpType) -> int:
	return upgrade_levels[powerup_type]

func get_upgrade_cost(powerup_type: PowerUpType) -> int:
	var current_level = upgrade_levels[powerup_type]
	return 100 * current_level * current_level  # Example: 100, 400, 900, 1600, etc.

func _process(delta: float) -> void:
	if active_powerup != PowerUpType.NONE:
		active_powerup_time_left -= delta
		if active_powerup_time_left <= 0:
			deactivate_powerup()

func activate_powerup(character_type: CharacterType) -> void:
	var powerup_data = powerups[character_type]
	var duration = get_powerup_duration(character_type)
	active_powerup = powerup_data["type"]
	active_powerup_time_left = duration
	PowerUpEffects.activate_powerup(active_powerup)
	emit_signal("powerup_activated", active_powerup, duration)
	print("Activating " + powerup_data["name"] + " for " + str(duration) + " seconds")

func deactivate_powerup() -> void:
	var deactivated_powerup = active_powerup
	active_powerup = PowerUpType.NONE
	active_powerup_time_left = 0
	PowerUpEffects.deactivate_powerup(deactivated_powerup)
	emit_signal("powerup_deactivated", deactivated_powerup)
	print("Powerup deactivated")


func get_active_powerup_time_left() -> float:
	return active_powerup_time_left

func get_active_powerup_type() -> PowerUpType:
	return active_powerup
