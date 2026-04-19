class_name RadioSignal

extends Node2D

var SignalTimerScene = preload("res://signal-timer/signal_timer.tscn")

signal signal_reached_target(emiter: BasePlanetSystem, target: BasePlanetSystem)

#Tu jeszcze musi być EnemyProbe
var receivers: Array[BasePlanetSystem] = []
var emiter: BasePlanetSystem = null
var distances: Array[float] = []
var radius = 0.0
var state = Enums.State.EXPANDING

func _ready() -> void:
	for i in range(receivers.size()):
		var signal_timer: SignalTimer = SignalTimerScene.instantiate() as SignalTimer
		signal_timer.initialize(distances[i])
		add_child(signal_timer)
		signal_timer.signal_reached_target.connect(_on_signal_reached_target.bind(receivers[i]))

func _process(delta):
	match state:
		Enums.State.EXPANDING:
			radius += Constants.SIGNAL_SPEED_PER_SECOND * delta
			if radius >= Constants.SIGNAL_RANGE:
				radius = Constants.SIGNAL_RANGE
				state = Enums.State.RETURNING

		Enums.State.RETURNING:
			radius -= Constants.SIGNAL_SPEED_PER_SECOND * delta
			if radius <= 0:
				queue_free()  # sygnał zakończony
	queue_redraw()

func _on_signal_reached_target(target: BasePlanetSystem) -> void:
	signal_reached_target.emit(self.emiter, target)

func initialize(emiter: BasePlanetSystem, receivers: Array[BasePlanetSystem], distances: Array[float]) -> void:
	self.emiter = emiter
	self.receivers = receivers
	self.distances = distances
	
func _draw() -> void:
	draw_arc(Vector2.ZERO,radius,0,TAU,64,Color(0, 1, 1, 1),2.0)
