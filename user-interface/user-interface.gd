class_name UserInterface

extends CanvasLayer

signal ping_earth()
signal ping_planet_system(system: PlanetSystem)
signal close()

var PopupEarthScene = preload("res://popup-earth/popup-earth.tscn")
var PopupPlanetSystemScene = preload("res://popup-planet-system/popup-planet-system.tscn")

@onready var time: Label = $MarginContainer/Time
@onready var points: Label = $MarginContainer/Points
@onready var container: MarginContainer = $MarginContainer

var current_popup: Control = null
var popup_opened: bool = false

func update_time(time: int) -> void:
	self.time.text = "Years past: " + str(time)

func update_points(points: int) -> void:
	self.points.text = "Points: " + str(points)

func open_popup_earth(earth: Earth) -> void:
	var popup: PopupEarth = PopupEarthScene.instantiate() as PopupEarth
	popup.initialize(earth)
	container.add_child(popup)
	popup.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	popup.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	current_popup = popup
	popup.ping.connect(on_ping_earth)
	popup.close.connect(close_popup)
	popup_opened = true

func open_popup_planet_system(system: BasePlanetSystem) -> void:
	var popup: PopupPlanetSystem = PopupPlanetSystemScene.instantiate() as PopupPlanetSystem
	popup.initialize(system)
	container.add_child(popup)
	popup.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	popup.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	current_popup = popup
	popup.close.connect(close_popup)
	popup.ping.connect(on_ping_planet_system)
	popup_opened = true
	
func close_popup() -> void:
	if current_popup != null:
		current_popup.queue_free()
		current_popup = null
		close.emit()
	popup_opened = false

func on_ping_planet_system(system: PlanetSystem) -> void:
	ping_planet_system.emit(system)

func on_ping_earth() -> void:
	emit_signal("ping_earth")
	close_popup()
