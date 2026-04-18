class_name BasePlanetSystem

extends Node2D

@onready var selection: Sprite2D = $Selection
@onready var planet_system_name: Label = $PlanetSystemName
@onready var relay_system_name: Label = $RelayStationName

var id: String = ""
var selected: bool = false

var station: RelayStation = null

func _ready() -> void:
	planet_system_name.text = self.id
	if station != null:
		relay_system_name.text = station.id

func initialize_base(id_text: String) -> void:
	self.id = id_text

func set_station(station_reference: RelayStation) -> void:
	self.station = station_reference

func set_selected(value: bool) -> void:
	selected = value
	selection.visible = value
