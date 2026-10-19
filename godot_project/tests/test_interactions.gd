extends SceneTree

func _init() -> void:
	print("--- НАЧАЛО ТЕСТИРОВАНИЯ ИГРОВОГО ДВИЖКА (25% MILESTONE) ---")
	var main_scene = load("res://scenes/main.tscn")
	if not main_scene:
		printerr("ОШИБКА: Не удалось загрузить main.tscn")
		quit(1)
		return
	
	var main_node = main_scene.instantiate()
	root.add_child(main_node)
	
	var yuki = main_node.get_node("Yuki")
	var anim_player: AnimationPlayer = yuki.get_node("AnimationPlayer")
	
	print("[OK] Сцена main.tscn и персонаж Yuki успешно инициализированы!")
	print("[OK] Доступные анимации в AnimationPlayer: ", anim_player.get_animation_list())
	
	# Проверка всех обязательных анимаций Talking Tom
	var required_anims = ["idle", "slap_left", "slap_right", "pet", "tickle", "listen", "eat"]
	for anim in required_anims:
		if not anim_player.has_animation(anim):
			printerr("ОШИБКА: Отсутствует анимация " + anim)
			quit(1)
			return
		print("[OK] Найдена анимация: " + anim + " (длительность: " + str(anim_player.get_animation(anim).length) + "с)")
	
	# Проверка реакций FSM
	print("[TEST] Проверка trigger_slap(true)...")
	yuki.trigger_slap(true)
	assert(yuki.current_state == yuki.State.SLAPPED)
	print("[OK] trigger_slap отработал штатно!")
	
	print("[TEST] Проверка trigger_pet()...")
	yuki.trigger_pet()
	assert(yuki.current_state == yuki.State.PETTING)
	print("[OK] trigger_pet отработал штатно!")
	
	print("[TEST] Проверка trigger_tickle()...")
	yuki.trigger_tickle()
	assert(yuki.current_state == yuki.State.TICKLED)
	print("[OK] trigger_tickle отработал штатно!")
	
	print("[TEST] Проверка trigger_eat()...")
	yuki.trigger_eat()
	assert(yuki.current_state == yuki.State.EATING)
	print("[OK] trigger_eat отработал штатно!")
	
	print("[TEST] Проверка trigger_listen()...")
	yuki.trigger_listen()
	assert(yuki.current_state == yuki.State.LISTENING)
	print("[OK] trigger_listen отработал штатно!")
	
	print("--- ВСЕ ТЕСТЫ 25% MILESTONE ПРОЙДЕНЫ УСПЕШНО (100% ВАЛИДАЦИЯ)! ---")
	quit(0)
