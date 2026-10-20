extends Node3D

const TextureStudio = preload("res://scripts/texture_studio.gd")
const SoundEffects = preload("res://scripts/sound_effects.gd")
const SaveManager = preload("res://scripts/save_manager.gd")
const MinigameCatcherScene = preload("res://scenes/minigame_catcher.tscn")
const WardrobeDialogScene = preload("res://scenes/wardrobe_dialog.tscn")

enum RoomType { LIVING, KITCHEN, BATHROOM, BEDROOM }

@onready var camera: Camera3D = $Camera3D
@onready var yuki: Node3D = $Yuki
@onready var dialogue_label: Label = $UI/DialogueBubble/Label
@onready var hunger_bar: ProgressBar = $UI/TopHUD/HBox/StatsGrid/HungerCol/HungerBar
@onready var hygiene_bar: ProgressBar = $UI/TopHUD/HBox/StatsGrid/HygieneCol/HygieneBar
@onready var energy_bar: ProgressBar = $UI/TopHUD/HBox/StatsGrid/EnergyCol/EnergyBar
@onready var mood_bar: ProgressBar = $UI/TopHUD/HBox/StatsGrid/MoodCol/MoodBar
@onready var gold_label: Label = $UI/TopHUD/HBox/Currency/GoldLabel
@onready var room_name_label: Label = $UI/TopHUD/HBox/RoomName

@onready var wardrobe_btn: Button = $UI/TopHUD/HBox/WardrobeBtn
@onready var arcade_btn: Button = $UI/TopHUD/HBox/ArcadeBtn

@onready var floor_mesh: MeshInstance3D = $Room/Floor
@onready var wall_mesh: MeshInstance3D = $Room/BackWall
@onready var sun_light: DirectionalLight3D = $SunLight
@onready var room_omni_light: OmniLight3D = $RoomOmniLight
@onready var bgm_player: AudioStreamPlayer = $BGMPlayer
@onready var sfx_player: AudioStreamPlayer = $SFXPlayer

# Контейнеры комнат
@onready var living_room_props: Node3D = $Room/LivingRoom
@onready var kitchen_props: Node3D = $Room/Kitchen
@onready var bathroom_props: Node3D = $Room/Bathroom
@onready var bedroom_props: Node3D = $Room/Bedroom

# Панели действий для каждой комнаты
@onready var living_actions: Control = $UI/ActionsBar/LivingActions
@onready var kitchen_actions: Control = $UI/ActionsBar/KitchenActions
@onready var bathroom_actions: Control = $UI/ActionsBar/BathroomActions
@onready var bedroom_actions: Control = $UI/ActionsBar/BedroomActions

# Кнопки навигации по комнатам
@onready var living_tab_btn: Button = $UI/RoomTabs/HBox/LivingTab
@onready var kitchen_tab_btn: Button = $UI/RoomTabs/HBox/KitchenTab
@onready var bathroom_tab_btn: Button = $UI/RoomTabs/HBox/BathroomTab
@onready var bedroom_tab_btn: Button = $UI/RoomTabs/HBox/BedroomTab

# Частицы комнат
@onready var bath_bubbles: GPUParticles3D = $Room/Bathroom/SoapBubbles
@onready var sleep_zzz: GPUParticles3D = $Room/Bedroom/SleepZzz

var current_room: RoomType = RoomType.LIVING
var save_data: Dictionary = {}
var hunger: float = 85.0
var hygiene: float = 90.0
var energy: float = 80.0
var mood: float = 95.0
var gold: int = 350

var is_lamp_on: bool = true
var is_music_playing: bool = false
var is_night_lamp_on: bool = true
var auto_save_timer: float = 15.0

func _ready() -> void:
	# Загрузка сохранений
	save_data = SaveManager.load_game()
	gold = save_data.get("gold", 350)
	hunger = save_data.get("hunger", 85.0)
	hygiene = save_data.get("hygiene", 90.0)
	energy = save_data.get("energy", 80.0)
	mood = save_data.get("mood", 95.0)

	if yuki and yuki.has_method("apply_customization"):
		yuki.apply_customization(
			save_data.get("equipped_sweater", "sweater_strawberry"),
			save_data.get("equipped_hair", "hair_sakura"),
			save_data.get("equipped_acc", "acc_none")
		)

	# Подключение сигналов персонажа
	if yuki.has_signal("petted"):
		yuki.petted.connect(_on_yuki_petted)
	if yuki.has_signal("slapped"):
		yuki.slapped.connect(_on_yuki_slapped)
	if yuki.has_signal("tickled"):
		yuki.tickled.connect(_on_yuki_tickled)
	if yuki.has_signal("burned_spicy"):
		yuki.burned_spicy.connect(_on_yuki_burned_spicy)
	if yuki.has_signal("washed"):
		yuki.washed.connect(_on_yuki_washed)
	if yuki.has_signal("slept"):
		yuki.slept.connect(_on_yuki_slept)

	# Подключение кнопок навигации по комнатам
	living_tab_btn.pressed.connect(func(): switch_room(RoomType.LIVING))
	kitchen_tab_btn.pressed.connect(func(): switch_room(RoomType.KITCHEN))
	bathroom_tab_btn.pressed.connect(func(): switch_room(RoomType.BATHROOM))
	bedroom_tab_btn.pressed.connect(func(): switch_room(RoomType.BEDROOM))

	# Кнопки быстрого меню: Гардероб и Мини-игра
	if wardrobe_btn:
		wardrobe_btn.pressed.connect(open_wardrobe)
	if arcade_btn:
		arcade_btn.pressed.connect(open_minigame)

	# Действия: Гостиная
	$UI/ActionsBar/LivingActions/PetBtn.pressed.connect(_on_pet_btn_pressed)
	$UI/ActionsBar/LivingActions/SlapBtn.pressed.connect(_on_slap_btn_pressed)
	$UI/ActionsBar/LivingActions/TickleBtn.pressed.connect(_on_tickle_btn_pressed)
	$UI/ActionsBar/LivingActions/LampBtn.pressed.connect(toggle_floor_lamp)
	$UI/ActionsBar/LivingActions/MusicBtn.pressed.connect(toggle_retro_music)
	$UI/ActionsBar/LivingActions/VoiceBtn.pressed.connect(_on_voice_btn_pressed)

	# Действия: Кухня (Еда)
	$UI/ActionsBar/KitchenActions/OnigiriBtn.pressed.connect(func(): feed_food("onigiri"))
	$UI/ActionsBar/KitchenActions/CakeBtn.pressed.connect(func(): feed_food("cake"))
	$UI/ActionsBar/KitchenActions/ChiliBtn.pressed.connect(func(): feed_food("chili"))
	$UI/ActionsBar/KitchenActions/TeaBtn.pressed.connect(func(): feed_food("tea"))

	# Действия: Ванная
	$UI/ActionsBar/BathroomActions/SoapBtn.pressed.connect(apply_soap)
	$UI/ActionsBar/BathroomActions/ShowerBtn.pressed.connect(take_shower)

	# Действия: Спальня
	$UI/ActionsBar/BedroomActions/SleepBtn.pressed.connect(toggle_bedroom_sleep)

	# Инициализация первой комнаты
	switch_room(RoomType.LIVING)
	update_hud()
	show_speech("Привет, хозяин! Я Юки! Выбирай комнаты снизу и взаимодействуй со мной! 🌸")

func _process(delta: float) -> void:
	# Слежение взглядом за курсором
	var viewport_size = get_viewport().get_visible_rect().size
	var mouse_pos = get_viewport().get_mouse_position()
	var rel_x = (mouse_pos.x / viewport_size.x) * 2.0 - 1.0
	var rel_y = (mouse_pos.y / viewport_size.y) * 2.0 - 1.0
	if yuki and yuki.has_method("set_look_target"):
		yuki.set_look_target(Vector2(rel_x, rel_y))

	# Медленное естественное снижение параметров (Тамагочи)
	if current_room == RoomType.BEDROOM and yuki.current_state == yuki.State.SLEEPING:
		energy = min(100.0, energy + 8.0 * delta)
	else:
		energy = max(0.0, energy - 0.25 * delta)
	
	hunger = max(0.0, hunger - 0.35 * delta)
	hygiene = max(0.0, hygiene - 0.2 * delta)
	mood = max(0.0, mood - 0.3 * delta)
	update_hud()

	# Периодическое автосохранение
	auto_save_timer -= delta
	if auto_save_timer <= 0.0:
		auto_save_timer = 15.0
		save_current_state()

# --- СИСТЕМА ПЕРЕКЛЮЧЕНИЯ КОМНАТ ---

func switch_room(new_room: RoomType) -> void:
	current_room = new_room
	
	# Скрыть все комнаты
	living_room_props.visible = (new_room == RoomType.LIVING)
	kitchen_props.visible = (new_room == RoomType.KITCHEN)
	bathroom_props.visible = (new_room == RoomType.BATHROOM)
	bedroom_props.visible = (new_room == RoomType.BEDROOM)

	# Переключить панели действий
	living_actions.visible = (new_room == RoomType.LIVING)
	kitchen_actions.visible = (new_room == RoomType.KITCHEN)
	bathroom_actions.visible = (new_room == RoomType.BATHROOM)
	bedroom_actions.visible = (new_room == RoomType.BEDROOM)

	# Настройка материалов и света для каждой комнаты
	match new_room:
		RoomType.LIVING:
			room_name_label.text = "🛋️ Гостиная"
			setup_living_room()
			show_speech("В гостиной так уютно! Можно включить радио или торшер! ✨")
		RoomType.KITCHEN:
			room_name_label.text = "🍙 Кухня"
			setup_kitchen()
			show_speech("Кухня! Я проголодалась, угости меня чем-нибудь вкусным! 🍙")
		RoomType.BATHROOM:
			room_name_label.text = "🛁 Ванная"
			setup_bathroom()
			show_speech("Ванная комната! Намыль меня мылом или включи душ! 🫧")
		RoomType.BEDROOM:
			room_name_label.text = "🛏️ Спальня"
			setup_bedroom()
			show_speech("Спальня... Если я устану, выключи свет и дай поспать! 💤")

func setup_living_room() -> void:
	var floor_mat = StandardMaterial3D.new()
	floor_mat.albedo_texture = TextureStudio.create_parquet_texture()
	floor_mat.uv1_scale = Vector3(4, 3, 1)
	floor_mat.roughness = 0.55
	if floor_mesh: floor_mesh.material_override = floor_mat

	var wall_mat = StandardMaterial3D.new()
	wall_mat.albedo_texture = TextureStudio.create_wallpaper_texture()
	wall_mat.uv1_scale = Vector3(3, 2, 1)
	wall_mat.roughness = 0.85
	if wall_mesh: wall_mesh.material_override = wall_mat

	sun_light.light_color = Color(1.0, 0.96, 0.90)
	sun_light.light_energy = 1.25
	room_omni_light.light_energy = 1.0 if is_lamp_on else 0.2
	room_omni_light.light_color = Color(1.0, 0.90, 0.78)
	if sleep_zzz: sleep_zzz.emitting = false

func setup_kitchen() -> void:
	var floor_mat = StandardMaterial3D.new()
	floor_mat.albedo_texture = TextureStudio.create_kitchen_tile_texture()
	floor_mat.uv1_scale = Vector3(5, 4, 1)
	floor_mat.roughness = 0.35
	if floor_mesh: floor_mesh.material_override = floor_mat

	var wall_mat = StandardMaterial3D.new()
	wall_mat.albedo_color = Color(1.0, 0.97, 0.94)
	wall_mat.roughness = 0.5
	if wall_mesh: wall_mesh.material_override = wall_mat

	sun_light.light_color = Color(1.0, 0.98, 0.92)
	sun_light.light_energy = 1.30
	room_omni_light.light_energy = 0.8
	room_omni_light.light_color = Color(1.0, 0.94, 0.85)
	if sleep_zzz: sleep_zzz.emitting = false

func setup_bathroom() -> void:
	var floor_mat = StandardMaterial3D.new()
	floor_mat.albedo_texture = TextureStudio.create_bathroom_tile_texture()
	floor_mat.uv1_scale = Vector3(6, 5, 1)
	floor_mat.roughness = 0.2
	floor_mat.metallic = 0.1
	if floor_mesh: floor_mesh.material_override = floor_mat

	var wall_mat = StandardMaterial3D.new()
	wall_mat.albedo_texture = TextureStudio.create_bathroom_tile_texture()
	wall_mat.uv1_scale = Vector3(4, 3, 1)
	wall_mat.roughness = 0.25
	if wall_mesh: wall_mesh.material_override = wall_mat

	sun_light.light_color = Color(0.92, 0.98, 1.0)
	sun_light.light_energy = 1.15
	room_omni_light.light_energy = 1.1
	room_omni_light.light_color = Color(0.85, 0.96, 1.0)
	if sleep_zzz: sleep_zzz.emitting = false

func setup_bedroom() -> void:
	var floor_mat = StandardMaterial3D.new()
	floor_mat.albedo_color = Color(0.82, 0.62, 0.45)
	floor_mat.roughness = 0.6
	if floor_mesh: floor_mesh.material_override = floor_mat

	var wall_mat = StandardMaterial3D.new()
	wall_mat.albedo_texture = TextureStudio.create_bedroom_wallpaper_texture()
	wall_mat.uv1_scale = Vector3(4, 3, 1)
	wall_mat.roughness = 0.8
	if wall_mesh: wall_mesh.material_override = wall_mat

	if is_night_lamp_on:
		sun_light.light_energy = 0.4
		room_omni_light.light_energy = 1.0
		room_omni_light.light_color = Color(1.0, 0.86, 0.58)
	else:
		sun_light.light_energy = 0.08
		room_omni_light.light_energy = 0.05

# --- ВЗАИМОДЕЙСТВИЕ В КОМНАТАХ ---

func toggle_floor_lamp() -> void:
	is_lamp_on = not is_lamp_on
	sfx_player.stream = SoundEffects.get_switch_sound()
	sfx_player.play()
	room_omni_light.light_energy = 1.0 if is_lamp_on else 0.2
	if is_lamp_on:
		show_speech("Щёлк! Стало светло и ярко! 💡")
	else:
		show_speech("Щёлк! Романтичный полумрак... 🕯️")

func toggle_retro_music() -> void:
	is_music_playing = not is_music_playing
	if is_music_playing:
		bgm_player.stream = SoundEffects.get_retro_tune_sound()
		bgm_player.play()
		if yuki.has_method("trigger_dance"):
			yuki.trigger_dance()
		show_speech("Ура, чиптюн-дискотека! Танцуем вместе! 🎶💃")
	else:
		bgm_player.stop()
		show_speech("Музыка выключена. Отдыхаем! ☕")

func feed_food(food_type: String) -> void:
	match food_type:
		"onigiri":
			hunger = min(100.0, hunger + 25.0)
			gold += 10
			if yuki.has_method("trigger_eat"):
				yuki.trigger_eat()
			show_speech("Ам-ням! Какое свежее рисовое онигири! Спасибо! 🍙 (+10 🪙)")
		"cake":
			hunger = min(100.0, hunger + 35.0)
			mood = min(100.0, mood + 15.0)
			gold += 15
			if yuki.has_method("trigger_eat"):
				yuki.trigger_eat()
			show_speech("Вау! Клубничный тортик со взбитыми сливками! Я на седьмом небе! 🍰✨")
		"chili":
			hunger = min(100.0, hunger + 10.0)
			mood = max(10.0, mood - 10.0)
			if yuki.has_method("trigger_spicy"):
				yuki.trigger_spicy()
			show_speech("А-А-А-А!! ОГОНЬ!! ПЕРЕЦ ЧИЛИ ОЧЕНЬ ОСТРЫЙ!! 🌶️🔥🥵")
		"tea":
			hunger = min(100.0, hunger + 15.0)
			mood = min(100.0, mood + 10.0)
			gold += 5
			if yuki.has_method("trigger_eat"):
				yuki.trigger_eat()
			show_speech("Глоток горячего зеленого чая маття... Освежает! 🍵")
	update_hud()

func apply_soap() -> void:
	if yuki.has_method("trigger_bath"):
		yuki.trigger_bath()
	if bath_bubbles:
		bath_bubbles.restart()
		bath_bubbles.emitting = true
	hygiene = min(100.0, hygiene + 20.0)
	mood = min(100.0, mood + 8.0)
	update_hud()
	show_speech("Пенка и пузырики! Какое ароматное мыло! 🫧")

func take_shower() -> void:
	sfx_player.stream = SoundEffects.get_water_sound()
	sfx_player.play()
	if yuki.has_method("trigger_bath"):
		yuki.trigger_bath()
	hygiene = 100.0
	mood = min(100.0, mood + 15.0)
	gold += 12
	update_hud()
	show_speech("Пш-ш-ш! Тёплый душ смыл всю пену! Я теперь идеально чистая! 🚿✨ (+12 🪙)")

func toggle_bedroom_sleep() -> void:
	is_night_lamp_on = not is_night_lamp_on
	sfx_player.stream = SoundEffects.get_switch_sound()
	sfx_player.play()
	
	if not is_night_lamp_on:
		sun_light.light_energy = 0.05
		room_omni_light.light_energy = 0.05
		if sleep_zzz:
			sleep_zzz.restart()
			sleep_zzz.emitting = true
		if yuki.has_method("trigger_sleep"):
			yuki.trigger_sleep()
		show_speech("Свет выключен. Юки сладко засыпает... Z-z-z... 🌙💤")
	else:
		sun_light.light_energy = 0.25
		room_omni_light.light_energy = 0.75
		if sleep_zzz:
			sleep_zzz.emitting = false
		if yuki.has_method("trigger_wake_up"):
			yuki.trigger_wake_up()
		show_speech("Доброе утро, хозяин! Я выспалась и полна сил! ☀️🌸")

# --- СИГНАЛЫ ПЕРСОНАЖА ---

func _on_yuki_petted() -> void:
	mood = min(100.0, mood + 6.0)
	gold += 2
	update_hud()
	show_speech("Мур-р... Так приятно гладишь! Ты самый лучший! ✨")

func _on_yuki_slapped() -> void:
	mood = max(10.0, mood - 15.0)
	update_hud()
	show_speech("Ой! Больно же! За что пощёчина?! 😿")

func _on_yuki_tickled() -> void:
	mood = min(100.0, mood + 5.0)
	update_hud()
	show_speech("Хи-хи-хи! Щекотно, перестань! 🌸")

func _on_yuki_burned_spicy() -> void:
	show_speech("ВОДЫ! СРОЧНО ВОДЫ!! РОТ ГОРИТ!! 🌶️💨")

func _on_yuki_washed() -> void:
	pass

func _on_yuki_slept() -> void:
	pass

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
	show_speech("Я внимательно слушаю тебя! 🎙️")
	
	# Через небольшую паузу Юки забавно отвечает с анимацией рта
	var timer = get_tree().create_timer(1.0)
	timer.timeout.connect(func():
		if yuki and yuki.has_method("trigger_talk"):
			yuki.trigger_talk(randf_range(0.95, 1.25))
		
		var quotes = []
		match current_room:
			RoomType.LIVING:
				quotes = [
					"Я обожаю, когда ты проводишь со мной время! ✨",
					"Давай включим музыку в радио и потанцуем! 🎶💃",
					"Ты самый заботливый друг на свете! 🌸",
					"Сыграем в Сладкий звездопад? Нажми на 🎮 вверху! 🍓"
				]
			RoomType.KITCHEN:
				quotes = [
					"М-м-м, пахнет так вкусно! Пора перекусить онигири! 🍙",
					"А тортик сегодня будет? Пожалуйста-пожалуйста! 🍰✨",
					"Только не корми меня больше тем острым перцем чили! 🌶️😅"
				]
			RoomType.BATHROOM:
				quotes = [
					"Пузырики такие радужные и блестящие! 🫧",
					"Теплая ванна — это рай после активного дня! 🛁",
					"Смотри, какой большой мыльный пузырь лопнул! 🫧✨"
				]
			RoomType.BEDROOM:
				quotes = [
					"Звёзды за окном так ярко сияют... 🌙",
					"Почитаешь мне сказку на ночь? 💤",
					"Я уже сладко зеваю... Спокойной ночи, хозяин! 😴"
				]
		show_speech(quotes[randi() % quotes.size()])
	)

func open_wardrobe() -> void:
	save_current_state()
	var wardrobe_instance = WardrobeDialogScene.instantiate()
	$UI.add_child(wardrobe_instance)
	wardrobe_instance.init_wardrobe(save_data)
	
	wardrobe_instance.item_equipped.connect(func(category, item_id):
		match category:
			"sweaters":
				save_data["equipped_sweater"] = item_id
				if yuki and yuki.has_method("set_sweater_style"):
					yuki.set_sweater_style(item_id)
			"hair":
				save_data["equipped_hair"] = item_id
				if yuki and yuki.has_method("set_hair_style"):
					yuki.set_hair_style(item_id)
			"accessories":
				save_data["equipped_acc"] = item_id
				if yuki and yuki.has_method("set_accessory"):
					yuki.set_accessory(item_id)
		SaveManager.save_game(save_data)
	)

	wardrobe_instance.wardrobe_closed.connect(func(updated_data):
		save_data = updated_data
		gold = save_data.get("gold", gold)
		update_hud()
		SaveManager.save_game(save_data)
		show_speech("Какой потрясающий новый наряд! Мне так идет! 👗✨")
	)

func open_minigame() -> void:
	save_current_state()
	var minigame_instance = MinigameCatcherScene.instantiate()
	$UI.add_child(minigame_instance)

	minigame_instance.minigame_closed.connect(func(earned_gold: int):
		gold += earned_gold
		mood = 100.0
		save_current_state()
		update_hud()
		if yuki and yuki.has_method("trigger_dance"):
			yuki.trigger_dance()
		show_speech("Ура-а-а! Отличная игра! Заработано +" + str(earned_gold) + " 🪙! Моё настроение на максимуме! 🍓✨")
	)

func save_current_state() -> void:
	save_data["gold"] = gold
	save_data["hunger"] = hunger
	save_data["hygiene"] = hygiene
	save_data["energy"] = energy
	save_data["mood"] = mood
	if yuki:
		if "current_sweater_id" in yuki:
			save_data["equipped_sweater"] = yuki.current_sweater_id
		if "current_hair_id" in yuki:
			save_data["equipped_hair"] = yuki.current_hair_id
		if "current_acc_id" in yuki:
			save_data["equipped_acc"] = yuki.current_acc_id
	SaveManager.save_game(save_data)

func show_speech(text: String) -> void:
	dialogue_label.text = text

func update_hud() -> void:
	hunger_bar.value = hunger
	hygiene_bar.value = hygiene
	energy_bar.value = energy
	mood_bar.value = mood
	gold_label.text = str(gold)
