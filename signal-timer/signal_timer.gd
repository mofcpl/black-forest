class_name SignalTimer

extends Node2D

signal signal_reached_target()

@onready var timer = $Timer

var time_to_reach: float

func _ready() -> void:
	timer.wait_time = time_to_reach
	timer.start()

func initialize(distance_to_target: float) -> void:
	self.time_to_reach = distance_to_target / Constants.SIGNAL_SPEED_PER_SECOND

func _on_timer_timeout() -> void:
	signal_reached_target.emit()
