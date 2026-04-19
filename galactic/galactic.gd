class_name Galactic

extends Node

signal planet_system_selected(system: BasePlanetSystem)

var BasePlanetSystemScene = preload("res://base-planet-system/base_planet_system.tscn")
var PlanetScene = preload("res://planet-system/planet_system.tscn")
var RelayStationScene = preload("res://relay-station/relay_station.tscn")
var EnemyProbeScene = preload("res://enemy-probe/enemy_probe.tscn")
var EarthScene = preload("res://earth/earth.tscn")
var RadioSignalScene = preload("res://radio-signal/radio_signal.tscn")

var planet_systems: Array[PlanetSystem] = []
var relay_stations: Array[RelayStation] = []
var enemy_probes: Array[EnemyProbe] = []
var signals: Array[BaseSignal] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generate_planet_systems(Vector2(250, 250), 40, 50)
	generate_enemy_probes(Vector2(5000, 5000), 2, 1000)
	_generate_earth()

func _generate_earth() -> void:
	var earth: Earth = EarthScene.instantiate() as Earth
	earth.initialize("Earth")
	var relay_station: RelayStation = RelayStationScene.instantiate() as RelayStation
	relay_station.set_id("Communication center")
	earth.set_station(relay_station)
	add_child(earth)
	earth.connect("clicked", _on_planet_system_select)

func create_radio_signal(source: BasePlanetSystem) -> void:
	var receivers: Array[BasePlanetSystem] = []
	var distances: Array[float] = []
	
	for system in planet_systems:
		if system != source:
			var distance: float = source.position.distance_to(system.position)
			if distance <= Constants.SIGNAL_RANGE:
				receivers.append(system)
				distances.append(distance)
	
	if receivers.size() > 0:
		var radio_signal: RadioSignal = RadioSignalScene.instantiate() as RadioSignal
		radio_signal.initialize(receivers, distances)
		add_child(radio_signal)

func generate_planet_systems(chunk_size: Vector2, chunk_multiplier: int, padding: float) -> void:
	# Calculate the bounds based on multiplier
	var half_range: float = (chunk_size.x * chunk_multiplier) / 2.0
	var min_bound: float = -half_range
	var max_bound: float = half_range
	
	# Calculate number of chunks in each direction
	var chunks_per_side: int = int(max_bound - min_bound) / int(chunk_size.x)
	
	# Iterate through each chunk
	for chunk_x in range(chunks_per_side):
		for chunk_y in range(chunks_per_side):
			# Calculate chunk bounds
			var chunk_min_x: float = min_bound + chunk_x * chunk_size.x
			var chunk_max_x: float = chunk_min_x + chunk_size.x
			var chunk_min_y: float = min_bound + chunk_y * chunk_size.y
			var chunk_max_y: float = chunk_min_y + chunk_size.y
			
			# Apply padding constraints
			var padded_min_x: float = chunk_min_x + padding
			var padded_max_x: float = chunk_max_x - padding
			var padded_min_y: float = chunk_min_y + padding
			var padded_max_y: float = chunk_max_y - padding
			
			# Generate random position within padded chunk
			var random_x: float = randf_range(padded_min_x, padded_max_x)
			var random_y: float = randf_range(padded_min_y, padded_max_y)
			var random_pos: Vector2 = Vector2(random_x, random_y)
			
			# Create PlanetSystem
			var planet_system: PlanetSystem = PlanetScene.instantiate() as PlanetSystem
			planet_system.position = random_pos
			planet_system.initialize(_generate_random_id(5), randf() < 0.5)
			
			# 50% chance to create RelayStation
			if randf() < 0.5:
				var relay_station: RelayStation = RelayStationScene.instantiate() as RelayStation
				relay_station.set_id(_generate_random_id(3))
				planet_system.set_station(relay_station)
				planet_system.add_child(relay_station)
				relay_stations.append(relay_station)
			
			planet_systems.append(planet_system)
			add_child(planet_system)
			planet_system.connect("clicked", _on_planet_system_select)


func generate_enemy_probes(chunk_size: Vector2, chunk_multiplier: int, padding: float) -> void:
	# Calculate the bounds based on multiplier
	var half_range: float = (chunk_size.x * chunk_multiplier) / 2.0
	var min_bound: float = -half_range
	var max_bound: float = half_range
	
	# Calculate number of chunks in each direction
	var chunks_per_side: int = int(max_bound - min_bound) / int(chunk_size.x)
	
	# Iterate through each chunk
	for chunk_x in range(chunks_per_side):
		for chunk_y in range(chunks_per_side):
			# Calculate chunk bounds
			var chunk_min_x: float = min_bound + chunk_x * chunk_size.x
			var chunk_max_x: float = chunk_min_x + chunk_size.x
			var chunk_min_y: float = min_bound + chunk_y * chunk_size.y
			var chunk_max_y: float = chunk_min_y + chunk_size.y
			
			# Apply padding constraints
			var padded_min_x: float = chunk_min_x + padding
			var padded_max_x: float = chunk_max_x - padding
			var padded_min_y: float = chunk_min_y + padding
			var padded_max_y: float = chunk_max_y - padding
			
			# Generate random position within padded chunk
			var random_x: float = randf_range(padded_min_x, padded_max_x)
			var random_y: float = randf_range(padded_min_y, padded_max_y)
			var random_pos: Vector2 = Vector2(random_x, random_y)
			
			# Create EnemyProbe
			var enemy_probe: EnemyProbe = EnemyProbeScene.instantiate() as EnemyProbe
			enemy_probe.position = random_pos
			
			enemy_probes.append(enemy_probe)
			add_child(enemy_probe)

func _on_planet_system_select(system: BasePlanetSystem) -> void: 
	planet_system_selected.emit(system)

func _generate_random_id(length: int) -> String:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var chars := "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	var result := ""
	for i in range(length):
		var idx := rng.randi_range(0, chars.length() - 1)
		result += chars.substr(idx, 1)
	return result
