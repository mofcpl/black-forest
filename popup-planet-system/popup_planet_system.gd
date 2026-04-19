class_name PopupPlanetSystem

extends Control

signal ping()
signal enabled(is_enabled: bool)
signal target(system: BasePlanetSystem)
signal close()

@onready var planet_system_name_label: Label = $Panel/MarginContainer/HBoxContainer/VBoxContainer/PlanetSystemName
@onready var relay_system_name_label: Label = $Panel/MarginContainer/HBoxContainer/VBoxContainer/StationName
@onready var target_menu: OptionButton = $Panel/MarginContainer/HBoxContainer/VBoxContainer2/OptionButton

var systems_in_range: Array[BasePlanetSystem] = []
var planet_system: BasePlanetSystem = null

func _ready() -> void:
	planet_system_name_label.text = planet_system.id
	relay_system_name_label.text = planet_system.station.id

func initialize(planet_system: BasePlanetSystem) -> void:
	self.planet_system = planet_system

func _on_ping_pressed() -> void:
	ping.emit()

func _on_close_pressed() -> void:
	close.emit()

func _on_check_button_toggled(toggled_on: bool) -> void:
	enabled.emit(toggled_on)

func _on_option_button_item_selected(index: int) -> void:
	target.emit(systems_in_range[index])
