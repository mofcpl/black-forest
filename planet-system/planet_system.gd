class_name PlanetSystem

extends BasePlanetSystem

@onready var picture: Sprite2D = $Picture

var discovered: bool = false
var habitable: bool = false

func _ready() -> void:
	super()

func initialize(id_text: String, habitable: bool) -> void:
	super.initialize_base(id_text)
	self.habitable = habitable

func discover() -> void:
	self.discovered = true;
	picture.visible = true;
