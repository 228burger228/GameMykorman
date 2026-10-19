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

	print("--- ВСЕ ТЕСТЫ 4 КОМНАТ И ИНТЕРАКТИВА УСПЕШНО ПРОЙДЕНЫ (100% ВАЛИДАЦИЯ)! ---")
