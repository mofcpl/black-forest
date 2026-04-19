extends Node

@onready var camera: Camera2D = $Camera2D
@onready var years_past_timer: Timer = $Timer
@onready var user_interface: UserInterface = $UserInterface

@export var pan_speed: float = 600.0
@export var mouse_pan_margin: float = 20.0

var discovered_habitable_systems: int = 0
var selected_planet_system: BasePlanetSystem = null
var time_pased: int = 0

func _ready() -> void:
	set_process(true)

func updateTime() -> void:
	time_pased += 1
	user_interface.update_time(time_pased)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	var dir: Vector2 = Vector2.ZERO

	# Keyboard (WSAD + arrow keys)
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		dir.x -= 1
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		dir.x += 1
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		dir.y -= 1
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		dir.y += 1

	# Mouse edge panning
	var vp := get_viewport()
	var mouse_pos := vp.get_mouse_position()
	var view_size: Vector2 = vp.get_visible_rect().size
	if mouse_pos.x <= mouse_pan_margin:
		dir.x -= 1
	elif mouse_pos.x >= view_size.x - mouse_pan_margin:
		dir.x += 1
	if mouse_pos.y <= mouse_pan_margin:
		dir.y -= 1
	elif mouse_pos.y >= view_size.y - mouse_pan_margin:
		dir.y += 1

	# Apply movement
	if dir != Vector2.ZERO: 
		dir = dir.normalized()
		camera.global_position += dir * pan_speed * delta

func _on_galactic_planet_system_selected(system: BasePlanetSystem) -> void:
	if (!user_interface.popup_opened):
		if selected_planet_system != null:
			selected_planet_system.set_selected(false)
		selected_planet_system = system
		selected_planet_system.set_selected(true)
		if system is Earth:
			user_interface.open_popup_earth(system)

func _on_timer_timeout() -> void:
	updateTime()

func _on_user_interface_close() -> void:
	if selected_planet_system != null:
		selected_planet_system.set_selected(false)
		selected_planet_system = null
