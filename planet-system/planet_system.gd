class_name PlanetSystem

extends BasePlanetSystem

@onready var picture: Sprite2D = $Picture
@onready var name_label: Label = $PlanetSystemName
@onready var habitable_label: Label = $Habitable

var known_destroyed: bool = false
var habitable: bool = false

func _ready() -> void:
	super()

func initialize(id_text: String, habitable: bool) -> void:
	super.initialize_base(id_text)
	self.habitable = habitable

func discover() -> bool:
	if destroyed:
		known_destroyed_label.visible = true
	if habitable == true:
		habitable_label.visible = true
	self.discovered = true;
	name_label.visible = true
	picture.visible = true;
	return habitable
