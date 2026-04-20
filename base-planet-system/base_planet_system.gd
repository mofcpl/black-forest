class_name BasePlanetSystem

extends Node2D
 
signal clicked(system: BasePlanetSystem)
signal radar_signal(system: BasePlanetSystem)
signal planet_system_destroyed()

@onready var selection: Sprite2D = $Selection
@onready var planet_system_name: Label = $PlanetSystemName
@onready var relay_system_name: Label = $RelayStationName
@onready var radar_timer: Timer = $RadarTimer
@onready var known_destroyed_label: Label = $KnowDestroyed

var id: String = ""
var selected: bool = false
var discovered: bool = false
var selected_receiver: BasePlanetSystem = null
var destroyed: bool = false
var enabled_radar: bool = false

#var station: RelayStation = null

func destroy() -> void:
	destroyed = true
	if discovered:
		known_destroyed_label.visible = true
	enabled_radar = false
	radar_timer.stop()
	planet_system_destroyed.emit()

func enable_radar(enabled: bool) -> void:
	enabled_radar = enabled
	radar_timer.start()

func _ready() -> void:
	planet_system_name.text = self.id
	#if station != null:
		#relay_system_name.text = station.id

func initialize_base(id_text: String) -> void:
	self.id = id_text

#func set_station(station_reference: RelayStation) -> void:
	#self.station = station_reference

func set_selected(value: bool) -> void:
	selected = value
	selection.visible = value

func _on_area_2d_mouse_entered() -> void:
	if selected == false and discovered:
		selection.visible = true
		selection.modulate.a = 0.2

func _on_area_2d_mouse_exited() -> void:
	if selected == false and discovered:
		selection.visible = false
		selection.modulate.a = 1

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		#if station:
		if discovered:
			selection.modulate.a = 1
			set_selected(true)
			emit_signal("clicked", self)


func _on_radar_timer_timeout() -> void:
	if discovered == true:
		radar_signal.emit(self)
