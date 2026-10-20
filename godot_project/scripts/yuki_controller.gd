extends Node3D
class_name YukiRiggedController

const TextureStudio = preload("res://scripts/texture_studio.gd")
const SoundEffects = preload("res://scripts/sound_effects.gd")

signal petted
signal slapped
signal tickled
signal fed
signal slept
signal woke_up
signal danced
signal washed
signal burned_spicy

enum State { IDLE, PETTING, SLAPPED, TICKLED, LISTENING, EATING, SLEEPING, SPICY, DANCING, BATHING }

var current_state: State = State.IDLE
var state_timer: float = 0.0

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var audio_player: AudioStreamPlayer3D = $AudioPlayer
@onready var impact_stars: GPUParticles3D = $ImpactStars
@onready var hearts_burst: GPUParticles3D = $HeartsBurst

@onready var head: Node3D = $Root/Hips/Spine/Neck/Head
@onready var jaw: Node3D = $Root/Hips/Spine/Neck/Head/Jaw
@onready var head_mesh: MeshInstance3D = $Root/Hips/Spine/Neck/Head/HeadMesh
@onready var torso_mesh: MeshInstance3D = $Root/Hips/Spine/TorsoMesh
@onready var collar: MeshInstance3D = $Root/Hips/Spine/Collar
@onready var left_arm: MeshInstance3D = $Root/Hips/Spine/LeftArm/ArmMesh
@onready var right_arm: MeshInstance3D = $Root/Hips/Spine/RightArm/ArmMesh
@onready var left_eye: MeshInstance3D = $Root/Hips/Spine/Neck/Head/LeftEye
@onready var right_eye: MeshInstance3D = $Root/Hips/Spine/Neck/Head/RightEye

@onready var hair_cap: MeshInstance3D = $Root/Hips/Spine/Neck/Head/HairCap
@onready var bangs: MeshInstance3D = $Root/Hips/Spine/Neck/Head/Bangs
@onready var left_twintail: MeshInstance3D = $Root/Hips/Spine/Neck/Head/LeftTwintail/TailMesh
@onready var right_twintail: MeshInstance3D = $Root/Hips/Spine/Neck/Head/RightTwintail/TailMesh
@onready var left_ear: Node3D = $Root/Hips/Spine/Neck/Head/LeftEar
@onready var right_ear: Node3D = $Root/Hips/Spine/Neck/Head/RightEar

@onready var acc_glasses: Node3D = $Root/Hips/Spine/Neck/Head/AccGlasses
@onready var acc_head_bow: MeshInstance3D = $Root/Hips/Spine/Neck/Head/AccHeadBow
@onready var acc_star_clip: MeshInstance3D = $Root/Hips/Spine/Neck/Head/AccStarClip

var current_sweater_id: String = "sweater_strawberry"
var current_hair_id: String = "hair_sakura"
var current_acc_id: String = "acc_none"

var talking_timer: float = 0.0

var look_target: Vector2 = Vector2.ZERO
var pointer_down_time: float = 0.0
var pointer_moved_dist: float = 0.0
var pointer_is_down: bool = false
var touch_started_on_head: bool = false
var touch_down_global_pos: Vector3 = Vector3.ZERO

func _ready() -> void:
	apply_hd_materials()
	play_animation("idle")

func apply_hd_materials() -> void:
	var eye_tex = TextureStudio.create_anime_eye_texture()
	var eye_mat = StandardMaterial3D.new()
	eye_mat.albedo_texture = eye_tex
	eye_mat.roughness = 0.2
	eye_mat.metallic = 0.1
	if left_eye: left_eye.material_override = eye_mat
	if right_eye: right_eye.material_override = eye_mat

	var face_tex = TextureStudio.create_face_texture()
	var face_mat = StandardMaterial3D.new()
	face_mat.albedo_texture = face_tex
	face_mat.roughness = 0.6
	if head_mesh: head_mesh.material_override = face_mat

	apply_customization(current_sweater_id, current_hair_id, current_acc_id)

func apply_customization(sweater_id: String, hair_id: String, acc_id: String) -> void:
	set_sweater_style(sweater_id)
	set_hair_style(hair_id)
	set_accessory(acc_id)

func set_sweater_style(sweater_id: String) -> void:
	current_sweater_id = sweater_id
	var col = Color(0.96, 0.48, 0.64)
	var emblem = "heart"
	match sweater_id:
		"sweater_strawberry":
			col = Color(0.96, 0.48, 0.64)
			emblem = "heart"
		"sweater_mint":
			col = Color(0.35, 0.85, 0.65)
			emblem = "clover"
		"sweater_cyber":
			col = Color(0.20, 0.24, 0.48)
			emblem = "star"
		"sweater_honey":
			col = Color(0.98, 0.72, 0.25)
			emblem = "paw"

	var sweat_tex = TextureStudio.create_sweater_texture(col, emblem)
	var sweat_mat = StandardMaterial3D.new()
	sweat_mat.albedo_texture = sweat_tex
	sweat_mat.roughness = 0.75
	if torso_mesh: torso_mesh.material_override = sweat_mat

	var trim_mat = StandardMaterial3D.new()
	trim_mat.albedo_color = col.lightened(0.15)
	trim_mat.roughness = 0.7
	if collar: collar.material_override = trim_mat
	if left_arm: left_arm.material_override = trim_mat
	if right_arm: right_arm.material_override = trim_mat

func set_hair_style(hair_id: String) -> void:
	current_hair_id = hair_id
	var base_col = Color(0.98, 0.62, 0.78)
	match hair_id:
		"hair_sakura":
			base_col = Color(0.98, 0.62, 0.78)
		"hair_azure":
			base_col = Color(0.32, 0.68, 0.98)
		"hair_golden":
			base_col = Color(1.0, 0.84, 0.38)
		"hair_lavender":
			base_col = Color(0.78, 0.60, 0.95)

	var hair_tex = TextureStudio.create_hair_texture(base_col)
	var hair_mat = StandardMaterial3D.new()
	hair_mat.albedo_texture = hair_tex
	hair_mat.roughness = 0.35

	if hair_cap: hair_cap.material_override = hair_mat
	if bangs: bangs.material_override = hair_mat
	if left_twintail: left_twintail.material_override = hair_mat
	if right_twintail: right_twintail.material_override = hair_mat
	if left_ear and left_ear.has_node("EarMesh"):
		(left_ear.get_node("EarMesh") as MeshInstance3D).material_override = hair_mat
	if right_ear and right_ear.has_node("EarMesh"):
		(right_ear.get_node("EarMesh") as MeshInstance3D).material_override = hair_mat

func set_accessory(acc_id: String) -> void:
	current_acc_id = acc_id
	if acc_glasses: acc_glasses.visible = (acc_id == "acc_glasses")
	if acc_head_bow: acc_head_bow.visible = (acc_id == "acc_bow")
	if acc_star_clip: acc_star_clip.visible = (acc_id == "acc_star")
	var is_neko = (acc_id == "acc_neko" or acc_id == "acc_none" or acc_id == "")
	if left_ear: left_ear.visible = is_neko
	if right_ear: right_ear.visible = is_neko

func trigger_talk(pitch_variation: float = 1.0) -> void:
	talking_timer = 0.85
	play_sound(SoundEffects.get_chibi_talk_sound(pitch_variation))

func _process(delta: float) -> void:
	if current_state != State.SLEEPING:
		state_timer -= delta

	# Анимация шевеления ртом при разговоре
	if talking_timer > 0.0:
		talking_timer -= delta
		var jaw_open = sin(talking_timer * 28.0) * 0.04
		if jaw:
			jaw.position.y = -0.16 + max(0.0, jaw_open)
	elif jaw and jaw.position.y != -0.16:
		jaw.position.y = -0.16

	if current_state == State.IDLE:
		# Плавное слежение взглядом за курсором
		head.rotation.y = lerp_angle(head.rotation.y, look_target.x * 0.32, 6.0 * delta)
		head.rotation.x = lerp_angle(head.rotation.x, -look_target.y * 0.20, 6.0 * delta)
	elif current_state != State.SLEEPING and state_timer <= 0.0:
		return_to_idle()

func return_to_idle() -> void:
	current_state = State.IDLE
	play_animation("idle")

func play_animation(anim_name: String, custom_blend: float = 0.15) -> void:
	if anim_player and anim_player.has_animation(anim_name):
		anim_player.play(anim_name, custom_blend)

# --- ПУБЛИЧНЫЕ РЕАКЦИИ ТОМА (TALKING TOM FSM) ---

func trigger_slap(from_left: bool = true) -> void:
	if current_state == State.SLEEPING:
		trigger_wake_up()
	current_state = State.SLAPPED
	state_timer = 0.95
	var anim = "slap_left" if from_left else "slap_right"
	play_animation(anim, 0.05)
	
	play_sound(SoundEffects.get_slap_sound())
	if impact_stars:
		impact_stars.restart()
		impact_stars.emitting = true
	slapped.emit()

func trigger_pet() -> void:
	if current_state == State.SLEEPING:
		return
	if current_state != State.PETTING:
		current_state = State.PETTING
		play_animation("pet", 0.2)
		play_sound(SoundEffects.get_purr_sound())
		if hearts_burst:
			hearts_burst.restart()
			hearts_burst.emitting = true
	state_timer = 0.75
	petted.emit()

func trigger_tickle() -> void:
	if current_state == State.SLEEPING:
		trigger_wake_up()
	current_state = State.TICKLED
	state_timer = 0.85
	play_animation("tickle", 0.1)
	play_sound(SoundEffects.get_giggle_sound())
	tickled.emit()

func trigger_eat() -> void:
	if current_state == State.SLEEPING:
		trigger_wake_up()
	current_state = State.EATING
	state_timer = 1.45
	play_animation("eat", 0.1)
	play_sound(SoundEffects.get_crunch_sound())
	fed.emit()

func trigger_spicy() -> void:
	if current_state == State.SLEEPING:
		trigger_wake_up()
	current_state = State.SPICY
	state_timer = 1.3
	play_animation("spicy", 0.08)
	play_sound(SoundEffects.get_spicy_sound())
	burned_spicy.emit()

func trigger_sleep() -> void:
	current_state = State.SLEEPING
	play_animation("sleep", 0.3)
	play_sound(SoundEffects.get_yawn_sound())
	slept.emit()

func trigger_wake_up() -> void:
	if current_state == State.SLEEPING:
		current_state = State.IDLE
		play_animation("idle", 0.2)
		play_sound(SoundEffects.get_giggle_sound())
		woke_up.emit()

func trigger_dance() -> void:
	if current_state == State.SLEEPING:
		trigger_wake_up()
	current_state = State.DANCING
	state_timer = 2.4
	play_animation("dance", 0.15)
	danced.emit()

func trigger_bath() -> void:
	if current_state == State.SLEEPING:
		trigger_wake_up()
	current_state = State.BATHING
	state_timer = 1.1
	play_animation("bath", 0.15)
	play_sound(SoundEffects.get_bubble_sound())
	if hearts_burst:
		hearts_burst.restart()
		hearts_burst.emitting = true
	washed.emit()

func trigger_listen() -> void:
	if current_state == State.SLEEPING:
		trigger_wake_up()
	current_state = State.LISTENING
	state_timer = 3.0
	play_animation("listen", 0.25)

func play_sound(stream: AudioStream) -> void:
	if audio_player and stream:
		audio_player.stream = stream
		audio_player.play()

func set_look_target(viewport_relative: Vector2) -> void:
	look_target = viewport_relative

# --- ОБРАБОТКА ХИТБОКСОВ И КАСАНИЙ ---

func _on_head_area_input_event(_camera, event, click_position, _normal, _shape_idx) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			pointer_is_down = true
			touch_started_on_head = true
			pointer_down_time = Time.get_ticks_msec() / 1000.0
			pointer_moved_dist = 0.0
			touch_down_global_pos = click_position
		else:
			_resolve_touch_release(click_position)
	elif event is InputEventMouseMotion and event.button_mask & MOUSE_BUTTON_MASK_LEFT:
		pointer_moved_dist += event.relative.length()
		if pointer_moved_dist > 18.0:
			trigger_pet()

func _on_belly_area_input_event(_camera, event, _position, _normal, _shape_idx) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		trigger_tickle()

func _unhandled_input(event: InputEvent) -> void:
	# Глобальный перехват отпускания мыши (если курсор ушел за пределы хитбокса во время удара)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		if pointer_is_down:
			_resolve_touch_release(touch_down_global_pos)

func _resolve_touch_release(hit_pos: Vector3) -> void:
	if not pointer_is_down:
		return
	pointer_is_down = false
	var hold_time = (Time.get_ticks_msec() / 1000.0) - pointer_down_time
	if touch_started_on_head:
		touch_started_on_head = false
		if hold_time < 0.25 and pointer_moved_dist < 16.0:
			var is_left = (hit_pos.x < head.global_position.x)
			trigger_slap(is_left)
		else:
			trigger_pet()
