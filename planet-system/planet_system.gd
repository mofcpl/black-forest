class_name PlanetSystem

extends BasePlanetSystem

@onready var picture: Sprite2D = $Picture
@onready var name_label: Label = $PlanetSystemName


var known_destroyed: bool = false
var habitable: bool = false

func _ready() -> void:
	super()

func initialize(id_text: String, habitable: bool) -> void:
	super.initialize_base(id_text)
	self.habitable = habitable

func discover() -> bool:
	self.discovered = true;
	name_label.visible = true
	picture.visible = true;
	return habitable
