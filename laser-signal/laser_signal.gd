class_name LaserSignal

extends RelayStation

var SignalTimerScene = preload("res://signal-timer/signal_timer.tscn")

signal signal_reached_target(target: BasePlanetSystem, data: PlanetSystem)

@onready var line: Line2D = $Line2D

var data: PlanetSystem = null
var target: BasePlanetSystem = null
var target_relative_position: Vector2 = Vector2.ZERO
var direction: Vector2
var distance: float
var progress = 0.0  # 0 → 1
var visible: bool = true

func _process(delta):
	if not visible:
		return
	var step = Constants.SIGNAL_SPEED_PER_SECOND * delta
	progress += step / distance
	
	if progress >= 1.0:
		progress = 1.0
		line.points[1] = target_relative_position
		return
	
	line.points[1] = direction * distance * progress


func _ready() -> void:
	var signal_timer: SignalTimer = SignalTimerScene.instantiate() as SignalTimer
	signal_timer.initialize(distance)
	add_child(signal_timer)
	signal_timer.signal_reached_target.connect(on_signal_timer_timeout)
	if not visible:
		line.visible = false
	else:
		line.width = 2.0
		line.default_color = Color(1, 0, 0, 1)
		line.points = [Vector2.ZERO, Vector2.ZERO]

func initialize(data: PlanetSystem, target: BasePlanetSystem, target_relative_position: Vector2, visible: bool) -> void:
	self.data = data
	self.target = target
	self.visible = visible
	self.target_relative_position = target_relative_position
	direction = target_relative_position.normalized()
	distance = target_relative_position.length()

func on_signal_timer_timeout() -> void:
	signal_reached_target.emit(target, data)
	queue_free()
