extends RelayStation

@onready var laser: Line2D = $Line2D

var data: Array[BasePlanetSystem] = []
var target: BasePlanetSystem = null
var target_relative_position: Vector2 = Vector2.ZERO



func initialize(data: Array[BasePlanetSystem], target: BasePlanetSystem) -> void:
	self.data = data
	self.target = target
	target_relative_position = target.position - self.position
