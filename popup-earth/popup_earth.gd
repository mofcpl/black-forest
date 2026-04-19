class_name PopupEarth

extends Control

signal ping()
signal close()

@onready var planet_system_name_label: Label = $Panel/MarginContainer/HBoxContainer/VBoxContainer/PlanetSystemName
@onready var relay_system_name_label: Label = $Panel/MarginContainer/HBoxContainer/VBoxContainer/StationName

var planet_system: BasePlanetSystem = null

func _ready() -> void:
	planet_system_name_label.text = planet_system.id
	#relay_system_name_label.text = planet_system.station.id

func initialize(planet_system: BasePlanetSystem) -> void:
	self.planet_system = planet_system

func _on_button_pressed() -> void:
	ping.emit()

func _on_close_pressed() -> void:
	close.emit()
