class_name PopupPlanetSystem

extends Control

signal ping(system: PlanetSystem)
signal enabled(is_enabled: bool)
signal change_selected_receiver(system: BasePlanetSystem)
signal close()

@onready var planet_system_name_label: Label = $Panel/MarginContainer/HBoxContainer/VBoxContainer/PlanetSystemName
#@onready var relay_system_name_label: Label = $Panel/MarginContainer/HBoxContainer/VBoxContainer/StationName
@onready var target_menu: OptionButton = $Panel/MarginContainer/HBoxContainer/VBoxContainer2/OptionButton

var systems_in_range: Array[BasePlanetSystem] = []
var planet_system: PlanetSystem = null

func _ready() -> void:
	planet_system_name_label.text = planet_system.id
	#relay_system_name_label.text = planet_system.station.id
	target_menu.add_item("Auto", 0)
	var i: int = 1
	for system in systems_in_range:
		target_menu.add_item(system.id, i)

func initialize(planet_system: PlanetSystem, systems_in_range: Array[BasePlanetSystem]) -> void:
	self.planet_system = planet_system
	self.systems_in_range = systems_in_range

func _on_ping_pressed() -> void:
	ping.emit(planet_system)

func _on_close_pressed() -> void:
	close.emit()

func _on_check_button_toggled(toggled_on: bool) -> void:
	planet_system.enable_radat()

func _on_option_button_item_selected(index: int) -> void:
	planet_system.selected_receiver = systems_in_range[index - 1]
