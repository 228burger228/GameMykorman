extends Node3D
class_name YukiCharacter

const TextureStudio = preload("res://scripts/texture_studio.gd")
const SoundEffects = preload("res://scripts/sound_effects.gd")

signal petted
signal slapped
signal tickled

enum State { IDLE, PETTING, SLAPPED, TICKLED, EATING, LISTENING }

var current_state: State = State.IDLE
var state_timer: float = 0.0

@onready var head: Node3D = $Head
@onready var body: Node3D = $Body
@onready var left_twintail: Node3D = $Head/LeftTwintail
@onready var right_twintail: Node3D = $Head/RightTwintail
@onready var mouth: Node3D = $Head/Mouth
@onready var left_eye: MeshInstance3D = $Head/LeftEye
@onready var right_eye: MeshInstance3D = $Head/RightEye
@onready var audio_player: AudioStreamPlayer3D = $AudioPlayer

var time: float = 0.0
var look_target_x: float = 0.0
var look_target_y: float = 0.0

# Переменные для отдачи при пощечине (Slap recoil)
var slap_wobble: float = 0.0
var slap_direction: float = 1.0

# Детектор поглаживания vs пощечины
var pointer_down_time: float = 0.0
var pointer_moved_dist: float = 0.0

func _ready() -> void:
	apply_hd_textures()

func apply_hd_textures() -> void:
	# 1. Текстура глаз
	var eye_tex = TextureStudio.create_anime_eye_texture()
	var eye_mat = StandardMaterial3D.new()
	eye_mat.albedo_texture = eye_tex
	eye_mat.roughness = 0.2
	eye_mat.metallic = 0.1
	if left_eye: left_eye.material_override = eye_mat
	if right_eye: right_eye.material_override = eye_mat

	# 2. Текстура лица
	var face_tex = TextureStudio.create_face_texture()
	var face_mat = StandardMaterial3D.new()
	face_mat.albedo_texture = face_tex
	face_mat.roughness = 0.6
	var head_mesh = $Head as MeshInstance3D
	if head_mesh: head_mesh.material_override = face_mat

	# 3. Текстура свитера
	var sweat_tex = TextureStudio.create_sweater_texture(Color(1.0, 0.44, 0.58))
	var sweat_mat = StandardMaterial3D.new()
	sweat_mat.albedo_texture = sweat_tex
	sweat_mat.roughness = 0.75
	var body_mesh = $Body as MeshInstance3D
	if body_mesh: body_mesh.material_override = sweat_mat

func _process(delta: float) -> void:
	time += delta
	state_timer -= delta

	match current_state:
		State.IDLE:
			process_idle(delta)
		State.PETTING:
			process_petting(delta)
		State.SLAPPED:
			process_slapped(delta)
		State.TICKLED:
			process_tickled(delta)
		State.EATING:
			process_eating(delta)
		State.LISTENING:
			process_listening(delta)

	# Пружинные хвостики
	var sway = sin(time * 2.8) * 0.08
	left_twintail.rotation.z = 0.5 + sway
	right_twintail.rotation.z = -0.5 - sway

func process_idle(delta: float) -> void:
	var breath = sin(time * 2.8) * 0.03
	body.scale = Vector3(1.0 + breath * 0.3, 1.0 - breath * 0.2, 1.0 + breath * 0.3)
	head.position.y = 1.95 + breath * 0.4

	# Слежение взглядом за курсором
	head.rotation.y = lerp_angle(head.rotation.y, look_target_x * 0.3, 8.0 * delta)
	head.rotation.x = lerp_angle(head.rotation.x, -look_target_y * 0.2, 8.0 * delta)
	head.rotation.z = lerp_angle(head.rotation.z, 0.0, 8.0 * delta)
	mouth.scale = Vector3(0.8, 0.2, 0.8)

func process_petting(delta: float) -> void:
	head.position.y = 1.9
	# Довольно наклоняет голову к руке
	head.rotation.z = lerp_angle(head.rotation.z, -0.25, 10.0 * delta)
	head.rotation.x = lerp_angle(head.rotation.x, 0.15, 10.0 * delta)
	mouth.scale = Vector3(0.9, 0.35, 0.8)
	
	if state_timer <= 0:
		current_state = State.IDLE

# ФИРМЕННАЯ ПОЩЕЧИНА ТОМА (SLAP & RECOIL)
func process_slapped(delta: float) -> void:
	slap_wobble = lerp(slap_wobble, 0.0, 6.0 * delta)
	var wobble_rot = sin(time * 24.0) * slap_wobble
	head.rotation.z = slap_direction * (0.35 + wobble_rot)
	head.rotation.x = -0.25 + wobble_rot * 0.5
	head.position.y = 1.85
	mouth.scale = Vector3(1.1, 0.6 + sin(time * 20.0) * 0.2, 0.9)

	if state_timer <= 0:
		head.rotation = Vector3.ZERO
		current_state = State.IDLE

func process_tickled(delta: float) -> void:
	var squash = sin(time * 18.0) * 0.15
	body.scale = Vector3(1.0 + squash, 1.0 - squash, 1.0 + squash)
	head.rotation.z = sin(time * 16.0) * 0.2
	mouth.scale = Vector3(1.0, 0.7, 0.9)

	if state_timer <= 0:
		body.scale = Vector3.ONE
		current_state = State.IDLE

func process_eating(delta: float) -> void:
	var chew = abs(sin(time * 14.0))
	mouth.scale = Vector3(0.9, chew * 1.4 + 0.2, 0.8)
	head.position.y = 1.95 + chew * 0.08
	if state_timer <= 0:
		current_state = State.IDLE

func process_listening(delta: float) -> void:
	head.rotation.y = 0.3
	head.rotation.z = 0.2
	head.position.y = 1.9
	if state_timer <= 0:
		current_state = State.IDLE

# --- ВЫЗОВ ДЕЙСТВИЙ И РЕАКЦИЙ ---

func trigger_slap(from_left: bool = true) -> void:
	current_state = State.SLAPPED
	state_timer = 0.9
	slap_direction = -1.0 if from_left else 1.0
	slap_wobble = 0.4
	play_sound(SoundEffects.get_slap_sound())
	slapped.emit()

func trigger_pet() -> void:
	current_state = State.PETTING
	state_timer = 0.6
	play_sound(SoundEffects.get_purr_sound())
	petted.emit()

func trigger_tickle() -> void:
	current_state = State.TICKLED
	state_timer = 0.8
	play_sound(SoundEffects.get_giggle_sound())
	tickled.emit()

func trigger_eat() -> void:
	current_state = State.EATING
	state_timer = 1.6
	play_sound(SoundEffects.get_crunch_sound())

func trigger_listen() -> void:
	current_state = State.LISTENING
	state_timer = 3.0

func play_sound(stream: AudioStream) -> void:
	if audio_player and stream:
		audio_player.stream = stream
		audio_player.play()

func set_look_target(viewport_relative: Vector2) -> void:
	look_target_x = clamp(viewport_relative.x, -1.0, 1.0)
	look_target_y = clamp(viewport_relative.y, -1.0, 1.0)

# Обработка клика по голове: короткий тап = пощечина, движение = поглаживание
func _on_head_area_input_event(_camera, event, _position, _normal, _shape_idx) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				pointer_down_time = Time.get_ticks_msec() / 1000.0
				pointer_moved_dist = 0.0
			else:
				var hold_time = (Time.get_ticks_msec() / 1000.0) - pointer_down_time
				if hold_time < 0.25 and pointer_moved_dist < 15.0:
					# Быстрый клик = ПОЩЕЧИНА ТОМА
					var is_left = (_position.x < head.global_position.x)
					trigger_slap(is_left)
				else:
					# Долгий тап или ведение пальцем = ПОГЛАЖИВАНИЕ
					trigger_pet()
	elif event is InputEventMouseMotion and event.button_mask & MOUSE_BUTTON_MASK_LEFT:
		pointer_moved_dist += event.relative.length()
		if pointer_moved_dist > 25.0:
			trigger_pet()

func _on_belly_area_input_event(_camera, event, _position, _normal, _shape_idx) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		trigger_tickle()
