class_name LaserSignal

extends RelayStation

var SignalTimerScene = preload("res://signal-timer/signal_timer.tscn")

signal signal_reached_target(laser_signal: LaserSignal)

@onready var line: Line2D = $Line2D

var data: PlanetSystem = null
var final_target: BasePlanetSystem = null
var current_target: BasePlanetSystem = null
var target_relative_position: Vector2 = Vector2.ZERO
var direction: Vector2
var distance: float
var progress = 0.0  # 0 → 1
var visible: bool = true
var laser_signal_type: Enums.LaserSignalType;

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


func start() -> void:
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

func initialize(laser_signal_type: Enums.LaserSignalType, data: PlanetSystem, current_target: BasePlanetSystem, final_target: BasePlanetSystem, target_relative_position: Vector2, visible: bool) -> void:
	self.laser_signal_type = laser_signal_type
	self.data = data
	self.current_target = current_target
	self.final_target = final_target
	self.visible = visible
	self.target_relative_position = target_relative_position
	direction = target_relative_position.normalized()
	distance = target_relative_position.length()

func set_next_target(next_target: BasePlanetSystem, target_relative_position: Vector2) -> void:
	current_target = next_target
	target_relative_position = target_relative_position
	direction = target_relative_position.normalized()
	distance = target_relative_position.length()
	progress = 0.0

func on_signal_timer_timeout() -> void:
	signal_reached_target.emit(self)
