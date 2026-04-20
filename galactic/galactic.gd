class_name Galactic

extends Node

signal planet_system_selected(system: BasePlanetSystem)
signal score()
signal game_over()

var BasePlanetSystemScene = preload("res://base-planet-system/base_planet_system.tscn")
var PlanetScene = preload("res://planet-system/planet_system.tscn")
var RelayStationScene = preload("res://relay-station/relay_station.tscn")
var EnemyProbeScene = preload("res://enemy-probe/enemy_probe.tscn")
var EarthScene = preload("res://earth/earth.tscn")
var RadioSignalScene = preload("res://radio-signal/radio_signal.tscn")
var LaserSignalScene = preload("res://laser-signal/laser_signal.tscn")

var planet_systems: Array[PlanetSystem] = []
var relay_stations: Array[RelayStation] = []
var enemy_probes: Array[EnemyProbe] = []
var signals: Array[BaseSignal] = []
var earth: Earth = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generate_planet_systems(Vector2(180, 180), 55, 40)
	generate_enemy_probes(Vector2(1000, 1000), 10, 200)
	_generate_earth()

func _generate_earth() -> void:
	var earth: Earth = EarthScene.instantiate() as Earth
	earth.initialize("Earth")
	earth.discovered = true
	var relay_station: RelayStation = RelayStationScene.instantiate() as RelayStation
	relay_station.set_id("Communication center")
	#earth.set_station(relay_station)
	add_child(earth)
	earth.connect("clicked", _on_planet_system_select)
	self.earth = earth
	earth.planet_system_destroyed.connect(on_earth_destroyed)

func on_earth_destroyed() -> void:
	game_over.emit()

func create_laser_signal(type: Enums.LaserSignalType, emiter: BasePlanetSystem, target: BasePlanetSystem, data: BasePlanetSystem, detected_probes: Array[EnemyProbe]) -> void:
	var laser_signal: LaserSignal = LaserSignalScene.instantiate() as LaserSignal
	match type:
		Enums.LaserSignalType.PING, Enums.LaserSignalType.RADAR:
			var next: BasePlanetSystem = null
			if emiter.selected_receiver != null:
				next = emiter.selected_receiver
			else:
				next = get_next_towards(emiter, target, Constants.SIGNAL_RANGE)
			#HACK z jakiegoś powodu nie znajduje stacji na skraju zasięgu
			if next == null:
				laser_signal.queue_free()
				return
			# HACK koniec
			laser_signal.initialize(type, data, next, target,  next.position - emiter.position, detected_probes, emiter.discovered)
			laser_signal.position = emiter.position
		Enums.LaserSignalType.COMMAND:
			var next = get_next_towards(earth, target, Constants.SIGNAL_RANGE)
			if next == null:
				laser_signal.queue_free()
				return
			laser_signal.initialize(type, null, next, target, next.position - earth.position, [], true)
			laser_signal.position = earth.position
	add_child(laser_signal)
	laser_signal.start()
	laser_signal.connect("signal_reached_target", on_laser_signal_received)

func on_laser_signal_received(laser_signal: LaserSignal) -> void:
	match laser_signal.laser_signal_type:
		Enums.LaserSignalType.PING, Enums.LaserSignalType.RADAR:
			if laser_signal.current_target is Earth:
				if laser_signal.data:
					laser_signal.data.discover()
					laser_signal.data.enable_radar(true)
					if laser_signal.data.habitable:
						score.emit()
				for probe in laser_signal.detected_probes:
					probe.detect()
				laser_signal.queue_free()
			else:
				var next: BasePlanetSystem = null
				if laser_signal.current_target.selected_receiver != null:
					next = laser_signal.current_target.selected_receiver
				else:
					next = get_next_towards(laser_signal.current_target, laser_signal.final_target, Constants.SIGNAL_RANGE)
				if next == null	or laser_signal.current_target.destroyed:
					laser_signal.queue_free()
					return
				laser_signal.position = laser_signal.current_target.position
				laser_signal.set_next_target(next, next.position - laser_signal.current_target.position, laser_signal.current_target.discovered)
				laser_signal.start()
		Enums.LaserSignalType.COMMAND:
			if laser_signal.current_target == laser_signal.final_target and laser_signal.current_target.destroyed == false:
				create_radio_signal(laser_signal.final_target)
				laser_signal.queue_free()
			else:
				var next = get_next_towards(laser_signal.current_target, laser_signal.final_target, Constants.SIGNAL_RANGE)
				#też nie wiem o co chodzi
				if next == null	or laser_signal.current_target.destroyed:
					laser_signal.queue_free()
					return
				# koniec hacka
				laser_signal.position = laser_signal.current_target.position
				laser_signal.set_next_target(next, next.position - laser_signal.current_target.position, laser_signal.current_target.discovered)
				laser_signal.start()		

func get_nearest_planet_systems(planet_system: BasePlanetSystem) -> Array[BasePlanetSystem]:
	var receivers: Array[BasePlanetSystem] = []

	for system in planet_systems:
		if system != planet_system and system != Earth and system.discovered:
			var distance: float = planet_system.position.distance_to(system.position)
			if distance <= Constants.SIGNAL_RANGE:
				receivers.append(system)
	return receivers

func create_radio_signal(source: BasePlanetSystem) -> void:
	var receivers: Array[PlanetSystem] = []
	var distances: Array[float] = []
	var probes: Array[EnemyProbe] = []
	var probes_distances: Array[float] = []
	
	for system in planet_systems:
		if system != source and system != Earth and system.destroyed == false:
			var distance: float = source.position.distance_to(system.position)
			if distance <= Constants.SIGNAL_RANGE:
				receivers.append(system)
				distances.append(distance)

	for probe in enemy_probes:
		var distance: float = source.position.distance_to(probe.position)
		if distance <= Constants.SIGNAL_RANGE:
			probes.append(probe)
			probes_distances.append(distance)
	
	var radio_signal: RadioSignal = RadioSignalScene.instantiate() as RadioSignal
	radio_signal.initialize(source, receivers, distances, probes, probes_distances)
	add_child(radio_signal)
	radio_signal.position = source.position
	radio_signal.connect("signal_reached_target",on_radio_signal_received)
	radio_signal.connect("signal_reached_probe",on_radio_signal_received_probe)

func on_radio_signal_received_probe(emiter: BasePlanetSystem, probe: EnemyProbe) -> void:
	probe.activate(emiter, earth)
	probe.no_target.connect(on_probe_no_target)

func on_probe_no_target(probe: EnemyProbe) -> void:
	probe.target = find_nearest_undestroyed_planet_system(probe.position)
	probe.activate(probe.target, earth)

func find_nearest_undestroyed_planet_system(position: Vector2) -> BasePlanetSystem:
	var best: BasePlanetSystem = earth
	var best_dist: float = position.distance_to(earth.position)

	for system in planet_systems:
		if system.destroyed:
			continue
		var dist: float = position.distance_to(system.position)
		if dist < best_dist:
			best_dist = dist
			best = system

	return best

func on_radio_signal_received(emiter: BasePlanetSystem, target: BasePlanetSystem) -> void:
	create_laser_signal(Enums.LaserSignalType.PING, target, earth, target, [])

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
			planet_system.habitable = randf() < 0.1  # 10% szans na habitowalny
			
			# 50% chance to create RelayStation
			# if randf() < 0.5:
			# 	var relay_station: RelayStation = RelayStationScene.instantiate() as RelayStation
			# 	relay_station.set_id(_generate_random_id(3))
			# 	planet_system.set_station(relay_station)
			# 	planet_system.add_child(relay_station)
			# 	relay_stations.append(relay_station)
			
			planet_systems.append(planet_system)
			add_child(planet_system)
			planet_system.connect("clicked", _on_planet_system_select)
			planet_system.connect("radar_signal", _on_radar_signal)

func _on_radar_signal(planet_system: BasePlanetSystem) -> void:
	var detected_probes: Array[EnemyProbe] = []
	for probe in enemy_probes:
		if probe.position.distance_to(planet_system.position) <= Constants.RADAR_RANGE:
			detected_probes.append(probe)
	if detected_probes.size() > 0:
		create_laser_signal(Enums.LaserSignalType.RADAR, planet_system, earth, null, detected_probes)

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

func get_next_towards(emitter: Node2D, target: Node2D, max_distance: float) -> BasePlanetSystem:
	var best = null
	var best_dist = INF

	var current_dist = emitter.position.distance_to(target.position)

	if current_dist <= max_distance:
		return target as BasePlanetSystem

	for candidate in planet_systems:
		if candidate == emitter or candidate.discovered == false:
			continue
		
		var dist_to_candidate = emitter.position.distance_to(candidate.position)
		if dist_to_candidate > max_distance +5:
			continue
		
		var dist_to_target = candidate.position.distance_to(target.position)
		
		# nie cofaj się
		if dist_to_target >= current_dist:
			continue
		
		if dist_to_target < best_dist:
			best_dist = dist_to_target
			best = candidate

	return best
