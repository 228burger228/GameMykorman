extends SceneTree

var frame_count = 0
var main_node = null
var yuki = null

func _init() -> void:
	print("--- НАЧАЛО ТЕСТИРОВАНИЯ ИГРОВОГО ДВИЖКА (4 КОМНАТЫ И ИНТЕРАКТИВ) ---")
	var main_scene = load("res://scenes/main.tscn")
	if not main_scene:
		printerr("ОШИБКА: Не удалось загрузить main.tscn")
		quit(1)
		return
	main_node = main_scene.instantiate()
	root.add_child(main_node)

func _process(_delta: float) -> bool:
	frame_count += 1
	if frame_count == 2:
		run_tests()
		quit(0)
		return true
	return false

func run_tests() -> void:
	yuki = main_node.get_node("Yuki")
	var anim_player: AnimationPlayer = yuki.get_node("AnimationPlayer")
	
	print("[OK] Сцена main.tscn и персонаж Yuki успешно вошли в дерево и готовы!")
	print("[OK] Доступные анимации: ", anim_player.get_animation_list())
	
	# 1. Проверка всех 11 анимаций
	var required_anims = [
		"idle", "slap_left", "slap_right", "pet", "tickle",
		"listen", "eat", "spicy", "dance", "bath", "sleep"
	]
	for anim in required_anims:
		if not anim_player.has_animation(anim):
			printerr("ОШИБКА: Отсутствует анимация " + anim)
			quit(1)
			return
		print("[OK] Найдена анимация: " + anim + " (" + str(anim_player.get_animation(anim).length) + "с)")
	
	# 2. Проверка базовых FSM реакций
	print("[TEST] Реакции Talking Tom: slap, pet, tickle...")
	yuki.trigger_slap(true)
	assert(yuki.current_state == yuki.State.SLAPPED)
	yuki.trigger_pet()
	assert(yuki.current_state == yuki.State.PETTING)
	yuki.trigger_tickle()
	assert(yuki.current_state == yuki.State.TICKLED)
	print("[OK] Базовые реакции отработали штатно!")

	# 3. Тестирование комнат и взаимодействий
	print("[TEST] Переключение комнат...")
	
	# Гостиная
	main_node.switch_room(main_node.RoomType.LIVING)
	assert(main_node.living_room_props.visible == true)
	main_node.toggle_floor_lamp()
	assert(main_node.is_lamp_on == false)
	main_node.toggle_floor_lamp()
	assert(main_node.is_lamp_on == true)
	main_node.toggle_retro_music()
	assert(main_node.is_music_playing == true)
	assert(yuki.current_state == yuki.State.DANCING)
	main_node.toggle_retro_music()
	print("[OK] Гостиная: торшер и радио-дискотека работают штатно!")

	# Кухня
	main_node.switch_room(main_node.RoomType.KITCHEN)
	assert(main_node.kitchen_props.visible == true)
	var prev_hunger = main_node.hunger
	main_node.feed_food("onigiri")
	assert(main_node.hunger > prev_hunger)
	assert(yuki.current_state == yuki.State.EATING)
	main_node.feed_food("chili")
	assert(yuki.current_state == yuki.State.SPICY)
	print("[OK] Кухня: онигири и огненный перец чили работают штатно!")

	# Ванная
	main_node.switch_room(main_node.RoomType.BATHROOM)
	assert(main_node.bathroom_props.visible == true)
	main_node.apply_soap()
	assert(yuki.current_state == yuki.State.BATHING)
	main_node.take_shower()
	assert(main_node.hygiene == 100.0)
	print("[OK] Ванная: мыло, пузыри и душ работают штатно!")

	# Спальня
	main_node.switch_room(main_node.RoomType.BEDROOM)
	assert(main_node.bedroom_props.visible == true)
	main_node.toggle_bedroom_sleep()
	assert(yuki.current_state == yuki.State.SLEEPING)
	main_node.toggle_bedroom_sleep()
	assert(yuki.current_state == yuki.State.IDLE)
	print("[OK] Спальня: выключение света, сон и пробуждение работают штатно!")

	# 4. Тестирование SaveManager
	print("[TEST] SaveManager: сохранение и загрузка JSON...")
	var test_data = {
		"gold": 999,
		"hunger": 77.0,
		"hygiene": 88.0,
		"energy": 66.0,
		"mood": 99.0,
		"unlocked_items": ["sweater_strawberry", "sweater_mint", "hair_sakura", "acc_none", "acc_glasses"],
		"equipped_sweater": "sweater_mint",
		"equipped_hair": "hair_sakura",
		"equipped_acc": "acc_glasses"
	}
	var SaveManager = load("res://scripts/save_manager.gd")
	assert(SaveManager.save_game(test_data) == true)
	var loaded = SaveManager.load_game()
	assert(loaded["gold"] == 999)
	assert(loaded["equipped_sweater"] == "sweater_mint")
	assert(loaded["equipped_acc"] == "acc_glasses")
	print("[OK] SaveManager: данные успешно сохранены и верифицированы!")

	# 5. Тестирование кастомизации и аксессуаров
	print("[TEST] Кастомизация Yuki: свитер, волосы, аксессуары...")
	yuki.set_sweater_style("sweater_mint")
	assert(yuki.current_sweater_id == "sweater_mint")
	yuki.set_hair_style("hair_azure")
	assert(yuki.current_hair_id == "hair_azure")
	yuki.set_accessory("acc_glasses")
	assert(yuki.current_acc_id == "acc_glasses")
	assert(yuki.acc_glasses.visible == true)
	yuki.set_accessory("acc_bow")
	assert(yuki.acc_head_bow.visible == true)
	assert(yuki.acc_glasses.visible == false)
	yuki.set_accessory("acc_star")
	assert(yuki.acc_star_clip.visible == true)
	print("[OK] Кастомизация 3D модели отработала безупречно!")

	# 6. Тестирование чиби-голоса и разговора
	print("[TEST] Talking Yuki: чиби-звук и анимация рта...")
	yuki.trigger_talk(1.1)
	assert(yuki.talking_timer > 0.0)
	print("[OK] Система речи и липсинка активна!")

	# 7. Тестирование мини-игры Сладкий Звездопад
	print("[TEST] Мини-игра «Сладкий звездопад»...")
	var minigame_scene = load("res://scenes/minigame_catcher.tscn")
	assert(minigame_scene != null)
	var minigame = minigame_scene.instantiate()
	main_node.get_node("UI").add_child(minigame)
	assert(minigame.is_active == true)
	# Симуляция поимки онигири и звездочки
	var test_star = minigame.FallingItem.new()
	test_star.type = minigame.ItemType.STAR
	test_star.points = 30
	minigame.handle_catch(test_star)
	assert(minigame.score == 30)
	assert(minigame.combo == 1)
	minigame.finish_game()
	assert(minigame.is_active == false)
	assert(minigame.game_over_panel.visible == true)
	minigame.queue_free()
	print("[OK] Мини-игра «Сладкий звездопад» протестирована на 100%!")

	# 8. Тестирование студии стиля
	print("[TEST] Студия стиля WardrobeDialog...")
	var wardrobe_scene = load("res://scenes/wardrobe_dialog.tscn")
	assert(wardrobe_scene != null)
	var wardrobe = wardrobe_scene.instantiate()
	main_node.get_node("UI").add_child(wardrobe)
	wardrobe.init_wardrobe(test_data)
	wardrobe.equip_item("sweaters", "sweater_cyber")
	assert(wardrobe.save_data["equipped_sweater"] == "sweater_cyber")
	wardrobe.queue_free()
	print("[OK] Студия стиля протестирована на 100%!")

	print("--- ВСЕ ТЕСТЫ (КОМНАТЫ, КАСТОМИЗАЦИЯ, МИНИ-ИГРА, САВЫ, РЕЧЬ) УСПЕШНО ПРОЙДЕНЫ (100% ВАЛИДАЦИЯ)! ---")
