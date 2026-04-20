class_name EnemyProbe

extends Node2D

signal no_target(probe: EnemyProbe)

@onready var picture: Sprite2D = $Picture
@onready var label: Label = $Label

var target: BasePlanetSystem = null
var activated: bool = false
var direction: Vector2 = Vector2.ZERO
var known_relative_position: Vector2 = Vector2.ZERO
var earth: Earth = null


func _ready() -> void:
	pass

func detect() -> void:
	picture.position = Vector2.ZERO
	picture.visible = true
	label.position = Vector2.ZERO
	label.visible = true
	known_relative_position = Vector2.ZERO


func activate(target: BasePlanetSystem, earth: Earth) -> void:
	self.target = target
	self.earth = earth
	activated = true
	direction = (target.position - position).normalized()


func _process(delta: float) -> void:
	if activated and target != null:
		var old_position = position

		# ruch sondy
		position += direction * Constants.ENEMY_PROBE_SPEED_PER_SECOND * delta

		# kompensacja ruchu sprite'a
		var movement = position - old_position
		if position.distance_to(earth.position) > Constants.RADAR_RANGE:
			picture.position -= movement
			label.position -= movement

		# dotarcie do celu
		if position.distance_to(target.position) < 10:
			target.destroy()
			if target.selected_receiver != null:
				self.target = target.selected_receiver
				direction = (target.position - position).normalized()
			else:
				activated = false
				no_target.emit(self)
