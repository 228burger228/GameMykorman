extends Node3D

@onready var camera: Camera3D = $Camera3D
@onready var yuki: Node3D = $Yuki
@onready var dialogue_label: Label = $UI/DialogueBubble/Label
@onready var hunger_bar: ProgressBar = $UI/TopHUD/StatsGrid/HungerBar
@onready var hygiene_bar: ProgressBar = $UI/TopHUD/StatsGrid/HygieneBar
@onready var energy_bar: ProgressBar = $UI/TopHUD/StatsGrid/EnergyBar
@onready var mood_bar: ProgressBar = $UI/TopHUD/StatsGrid/MoodBar
@onready var gold_label: Label = $UI/TopHUD/TopRow/Currency/GoldLabel

const ROOM_WIDTH: float = 14.0

var current_room: int = 0
var target_cam_x: float = 0.0

var hunger: float = 85.0
var hygiene: float = 90.0
var energy: float = 75.0
var mood: float = 95.0
var gold: int = 350

var touch_start_x: float = 0.0
var is_swiping: bool = false

func _ready() -> void:
	update_hud()
	show_speech("Привет, хозяин! Я Юки на движке Godot 4! 🌸")

	if yuki.has_signal("petted"):
		yuki.petted.connect(_on_yuki_petted)
	if yuki.has_signal("tickled"):
		yuki.tickled.connect(_on_yuki_tickled)

	$UI/ActionsBar/FeedBtn.pressed.connect(_on_feed_btn_pressed)
	$UI/ActionsBar/BathBtn.pressed.connect(_on_bath_btn_pressed)
	$UI/ActionsBar/SleepBtn.pressed.connect(_on_sleep_btn_pressed)

	$UI/BottomDock/Room0Btn.pressed.connect(func(): switch_room(0))
	$UI/BottomDock/Room1Btn.pressed.connect(func(): switch_room(1))
	$UI/BottomDock/Room2Btn.pressed.connect(func(): switch_room(2))
	$UI/BottomDock/Room3Btn.pressed.connect(func(): switch_room(3))

func _process(delta: float) -> void:
	camera.position.x = lerp(camera.position.x, target_cam_x, 8.0 * delta)
	yuki.position.x = lerp(yuki.position.x, target_cam_x, 9.0 * delta)

	var viewport_size = get_viewport().get_visible_rect().size
	var mouse_pos = get_viewport().get_mouse_position()
	var rel_x = (mouse_pos.x / viewport_size.x) * 2.0 - 1.0
	var rel_y = (mouse_pos.y / viewport_size.y) * 2.0 - 1.0
	if yuki.has_method("set_look_target"):
		yuki.set_look_target(Vector2(rel_x, rel_y))

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				touch_start_x = event.position.x
				is_swiping = true
			else:
				if is_swiping:
					var delta_x = event.position.x - touch_start_x
					if abs(delta_x) > 60:
						if delta_x < 0 and current_room < 3:
							switch_room(current_room + 1)
						elif delta_x > 0 and current_room > 0:
							switch_room(current_room - 1)
					is_swiping = false

func switch_room(room_idx: int) -> void:
	current_room = room_idx
	target_cam_x = current_room * ROOM_WIDTH
	var names = ["Гостиная", "Кухня", "Ванная", "Спальня"]
	show_speech("Локация: " + names[current_room] + "! ✨")

func show_speech(text: String) -> void:
	dialogue_label.text = text

func update_hud() -> void:
	hunger_bar.value = hunger
	hygiene_bar.value = hygiene
	energy_bar.value = energy
	mood_bar.value = mood
	gold_label.text = str(gold)

func _on_yuki_petted() -> void:
	mood = min(100.0, mood + 8.0)
	update_hud()
	show_speech("Мур-р... Ты так приятно гладишь! ✨")

func _on_yuki_tickled() -> void:
	show_speech("Ой, хи-хи-хи! Щекотно же! 🌸")

func _on_feed_btn_pressed() -> void:
	hunger = min(100.0, hunger + 25.0)
	gold += 10
	update_hud()
	if yuki.has_method("chew"):
		yuki.chew(1.8)
	show_speech("Ам! Как вкусно! Спасибо за угощение! 🍙")

func _on_bath_btn_pressed() -> void:
	hygiene = 100.0
	update_hud()
	show_speech("Теплая ванна — чистота и свежесть! 🛁")

func _on_sleep_btn_pressed() -> void:
	energy = 100.0
	update_hud()
	show_speech("Сладких снов... Zzz... Полный заряд энергии! 🌙")
