extends Node3D

const TextureStudio = preload("res://scripts/texture_studio.gd")
const SoundEffects = preload("res://scripts/sound_effects.gd")

@onready var camera: Camera3D = $Camera3D
@onready var yuki: Node3D = $Yuki
@onready var dialogue_label: Label = $UI/DialogueBubble/Label
@onready var hunger_bar: ProgressBar = $UI/TopHUD/StatsGrid/HungerBar
@onready var hygiene_bar: ProgressBar = $UI/TopHUD/StatsGrid/HygieneBar
@onready var energy_bar: ProgressBar = $UI/TopHUD/StatsGrid/EnergyBar
@onready var mood_bar: ProgressBar = $UI/TopHUD/StatsGrid/MoodBar
@onready var gold_label: Label = $UI/TopHUD/TopRow/Currency/GoldLabel
@onready var floor_mesh: MeshInstance3D = $Room/Floor
@onready var wall_mesh: MeshInstance3D = $Room/BackWall

var hunger: float = 85.0
var hygiene: float = 90.0
var energy: float = 75.0
var mood: float = 95.0
var gold: int = 350

func _ready() -> void:
	setup_room_materials()
	update_hud()
	show_speech("Привет, хозяин! Я твоя 3D-спутница Юки! Погладь меня или кликни по щёчке! 🌸")

	if yuki.has_signal("petted"):
		yuki.petted.connect(_on_yuki_petted)
	if yuki.has_signal("slapped"):
		yuki.slapped.connect(_on_yuki_slapped)
	if yuki.has_signal("tickled"):
		yuki.tickled.connect(_on_yuki_tickled)

	$UI/ActionsBar/FeedBtn.pressed.connect(_on_feed_btn_pressed)
	$UI/ActionsBar/PetBtn.pressed.connect(_on_pet_btn_pressed)
	$UI/ActionsBar/SlapBtn.pressed.connect(_on_slap_btn_pressed)
	$UI/ActionsBar/TickleBtn.pressed.connect(_on_tickle_btn_pressed)
	$UI/ActionsBar/VoiceBtn.pressed.connect(_on_voice_btn_pressed)

func setup_room_materials() -> void:
	# Паркетный деревянный пол
	var parquet_tex = TextureStudio.create_parquet_texture()
	var floor_mat = StandardMaterial3D.new()
	floor_mat.albedo_texture = parquet_tex
	floor_mat.uv1_scale = Vector3(4, 3, 1)
	floor_mat.roughness = 0.55
	if floor_mesh: floor_mesh.material_override = floor_mat

	# Обои в полоску
	var wall_tex = TextureStudio.create_wallpaper_texture()
	var wall_mat = StandardMaterial3D.new()
	wall_mat.albedo_texture = wall_tex
	wall_mat.uv1_scale = Vector3(3, 2, 1)
	wall_mat.roughness = 0.85
	if wall_mesh: wall_mesh.material_override = wall_mat

func _process(delta: float) -> void:
	# Слежение взглядом за курсором
	var viewport_size = get_viewport().get_visible_rect().size
	var mouse_pos = get_viewport().get_mouse_position()
	var rel_x = (mouse_pos.x / viewport_size.x) * 2.0 - 1.0
	var rel_y = (mouse_pos.y / viewport_size.y) * 2.0 - 1.0
	if yuki and yuki.has_method("set_look_target"):
		yuki.set_look_target(Vector2(rel_x, rel_y))

func show_speech(text: String) -> void:
	dialogue_label.text = text

func update_hud() -> void:
	hunger_bar.value = hunger
	hygiene_bar.value = hygiene
	energy_bar.value = energy
	mood_bar.value = mood
	gold_label.text = str(gold)

# --- РЕАКЦИИ ТОМА (TALKING TOM FSM) ---

func _on_yuki_petted() -> void:
	mood = min(100.0, mood + 6.0)
	gold += 2
	update_hud()
	show_speech("Мур-р... Так нежно гладишь! Ты лучший! ✨")

func _on_yuki_slapped() -> void:
	mood = max(10.0, mood - 15.0)
	update_hud()
	show_speech("Ой! Больно же! За что пощёчина?! 😿")

func _on_yuki_tickled() -> void:
	mood = min(100.0, mood + 5.0)
	update_hud()
	show_speech("Хи-хи-хи! Щекотно, перестань! 🌸")

func _on_feed_btn_pressed() -> void:
	hunger = min(100.0, hunger + 25.0)
	gold += 10
	update_hud()
	if yuki.has_method("trigger_eat"):
		yuki.trigger_eat()
	show_speech("Ам-ням! Какое вкусное онигири! Спасибо! 🍙 (+10 🪙)")

func _on_pet_btn_pressed() -> void:
	if yuki.has_method("trigger_pet"):
		yuki.trigger_pet()

func _on_slap_btn_pressed() -> void:
	if yuki.has_method("trigger_slap"):
		yuki.trigger_slap(true)

func _on_tickle_btn_pressed() -> void:
	if yuki.has_method("trigger_tickle"):
		yuki.trigger_tickle()

func _on_voice_btn_pressed() -> void:
	if yuki.has_method("trigger_listen"):
		yuki.trigger_listen()
	show_speech("Я внимательно слушаю тебя! (Режим Тома: приставила лапку к ушку) 🎙️")
