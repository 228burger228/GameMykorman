extends Node3D
class_name YukiCharacter

signal petted
signal tickled

@onready var head: Node3D = $Head
@onready var body: Node3D = $Body
@onready var left_twintail: Node3D = $Head/LeftTwintail
@onready var right_twintail: Node3D = $Head/RightTwintail
@onready var mouth: Node3D = $Head/Mouth

var time: float = 0.0
var chewing_timer: float = 0.0
var look_target_x: float = 0.0
var look_target_y: float = 0.0

func _process(delta: float) -> void:
	time += delta

	# Дыхание (Idle breathing)
	var breath = sin(time * 2.8) * 0.03
	body.scale = Vector3(1.0 + breath * 0.3, 1.0 - breath * 0.2, 1.0 + breath * 0.3)
	head.position.y = 1.95 + breath * 0.4

	# Пружинящие хвостики
	var sway = sin(time * 2.5) * 0.08
	left_twintail.rotation.z = 0.5 + sway
	right_twintail.rotation.z = -0.5 - sway

	# Плавное слежение взглядом за курсором/пальцем
	head.rotation.y = lerp_angle(head.rotation.y, look_target_x * 0.35, 0.1)
	head.rotation.x = lerp_angle(head.rotation.x, -look_target_y * 0.25, 0.1)

	# Жевание еды
	if chewing_timer > 0.0:
		chewing_timer -= delta
		var chew = abs(sin(time * 16.0))
		mouth.scale = Vector3(0.8, chew * 1.5, 0.8)
	else:
		mouth.scale = Vector3(0.8, 0.2, 0.8)

func set_look_target(viewport_relative: Vector2) -> void:
	look_target_x = clamp(viewport_relative.x, -1.0, 1.0)
	look_target_y = clamp(viewport_relative.y, -1.0, 1.0)

func chew(duration: float = 1.5) -> void:
	chewing_timer = duration

func _on_head_area_input_event(_camera, event, _position, _normal, _shape_idx) -> void:
	if event is InputEventMouseButton and event.pressed:
		petted.emit()

func _on_belly_area_input_event(_camera, event, _position, _normal, _shape_idx) -> void:
	if event is InputEventMouseButton and event.pressed:
		tickled.emit()
