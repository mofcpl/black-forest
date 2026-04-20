class_name PopupGameOver

extends Control

@onready var score_label: Label = $Panel/MarginContainer/VBoxContainer/Score

var score: int = 0

func _ready():
	self.score_label.text = "Discovered habitable planetary systems: " + str(score)

func initialize(score: int) -> void:
	self.score = score
