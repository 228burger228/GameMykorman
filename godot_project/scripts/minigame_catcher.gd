class_name MinigameCatcher
extends Control

signal minigame_closed(earned_gold: int)

const SoundEffects = preload("res://scripts/sound_effects.gd")

# Типы падающих предметов
enum ItemType { MACARON, ONIGIRI, STAR, CHILI }

class FallingItem:
	var type: ItemType
	var pos: Vector2
	var speed: float
	var size: Vector2 = Vector2(40, 40)
	var label: String
	var color: Color
	var points: int

var is_active: bool = false
var score: int = 0
var lives: int = 3
var time_left: float = 35.0
var combo: int = 0
var basket_x: float = 225.0
var basket_width: float = 80.0
var basket_height: float = 24.0

var items: Array[FallingItem] = []
var spawn_timer: float = 0.0
var shake_amount: float = 0.0

@onready var score_label: Label = $HUD/HBox/ScoreLabel
@onready var timer_label: Label = $HUD/HBox/TimerLabel
@onready var lives_label: Label = $HUD/HBox/LivesLabel
@onready var combo_label: Label = $HUD/ComboLabel
@onready var basket_panel: Panel = $GameArea/Basket
@onready var items_container: Control = $GameArea/ItemsContainer
@onready var game_over_panel: PanelContainer = $GameOverModal
@onready var final_score_label: Label = $GameOverModal/VBox/ScoreResult
@onready var reward_label: Label = $GameOverModal/VBox/RewardResult
@onready var sfx_player: AudioStreamPlayer = $SFXPlayer

func _ready() -> void:
	game_over_panel.visible = false
	$GameOverModal/VBox/ClaimBtn.pressed.connect(_on_claim_pressed)
	$GameOverModal/VBox/RestartBtn.pressed.connect(start_game)
	$HUD/HBox/CloseBtn.pressed.connect(_on_close_clicked)
	start_game()

func start_game() -> void:
	is_active = true
	score = 0
	lives = 3
	time_left = 35.0
	combo = 0
	basket_x = 225.0
	items.clear()
	game_over_panel.visible = false
	update_hud()

func _input(event: InputEvent) -> void:
	if not is_active:
		return
	if event is InputEventMouseMotion:
		basket_x = clampf(event.position.x, basket_width * 0.5 + 10.0, 450.0 - basket_width * 0.5 - 10.0)
	elif event is InputEventScreenDrag or event is InputEventScreenTouch:
		basket_x = clampf(event.position.x, basket_width * 0.5 + 10.0, 450.0 - basket_width * 0.5 - 10.0)

func _process(delta: float) -> void:
	if not is_active:
		return

	# Таймер раунда
	time_left -= delta
	if time_left <= 0.0:
		time_left = 0.0
		finish_game()
		return

	# Спавн предметов
	spawn_timer -= delta
	if spawn_timer <= 0.0:
		spawn_item()
		spawn_timer = randf_range(0.45, 0.75)

	# Позиция корзинки
	var basket_y = 660.0
	basket_panel.position = Vector2(basket_x - basket_width * 0.5, basket_y)

	# Движение и коллизии падающих предметов
	var i = items.size() - 1
	while i >= 0:
		var item = items[i]
		item.pos.y += item.speed * delta

		# Проверка коллизии с корзинкой
		var item_rect = Rect2(item.pos - item.size * 0.5, item.size)
		var basket_rect = Rect2(Vector2(basket_x - basket_width * 0.5, basket_y), Vector2(basket_width, basket_height))

		if item_rect.intersects(basket_rect):
			# Пойман!
			handle_catch(item)
			items.remove_at(i)
		elif item.pos.y > 720.0:
			# Упал за экран
			if item.type != ItemType.CHILI:
				combo = 0 # Сброс комбо при пропуске сладости
			items.remove_at(i)
		i -= 1

	# Встряска при ошибке
	if shake_amount > 0.0:
		shake_amount = max(0.0, shake_amount - delta * 20.0)
		position = Vector2(randf_range(-shake_amount, shake_amount), randf_range(-shake_amount, shake_amount))
	else:
		position = Vector2.ZERO

	queue_redraw()
	update_hud()

func spawn_item() -> void:
	var roll = randf()
	var item = FallingItem.new()
	item.pos = Vector2(randf_range(40.0, 410.0), -20.0)
	item.speed = randf_range(200.0, 320.0)

	if roll < 0.45:
		item.type = ItemType.MACARON
		item.label = "🍓"
		item.color = Color(1.0, 0.5, 0.65)
		item.points = 10
	elif roll < 0.75:
		item.type = ItemType.ONIGIRI
		item.label = "🍙"
		item.color = Color(0.95, 0.95, 0.95)
		item.points = 15
	elif roll < 0.88:
		item.type = ItemType.STAR
		item.label = "⭐"
		item.color = Color(1.0, 0.9, 0.2)
		item.points = 30
		item.speed *= 1.2
	else:
		item.type = ItemType.CHILI
		item.label = "🌶️"
		item.color = Color(1.0, 0.2, 0.2)
		item.points = -25

	items.append(item)

func handle_catch(item: FallingItem) -> void:
	if item.type == ItemType.CHILI:
		lives -= 1
		combo = 0
		shake_amount = 8.0
		sfx_player.stream = SoundEffects.get_hazard_hit_sound()
		sfx_player.play()
		if lives <= 0:
			finish_game()
	else:
		combo += 1
		var multiplier = 1 + int(combo / 4)
		score += item.points * multiplier
		sfx_player.stream = SoundEffects.get_item_pickup_sound()
		sfx_player.play()

func _draw() -> void:
	# Отрисовка падающих предметов
	for item in items:
		var center = item.pos
		var radius = item.size.x * 0.5
		# Неоновое свечение вокруг бонуса
		draw_circle(center, radius + 3.0, Color(item.color.r, item.color.g, item.color.b, 0.25))
		draw_circle(center, radius, item.color)
		# Контур
		draw_arc(center, radius, 0.0, TAU, 24, Color(1, 1, 1, 0.6), 1.5)

func update_hud() -> void:
	score_label.text = "Счёт: " + str(score)
	timer_label.text = "⏱️ " + str(int(time_left)) + "с"
	
	var hearts = ""
	for idx in range(3):
		hearts += "❤️" if idx < lives else "🖤"
	lives_label.text = hearts

	if combo >= 2:
		combo_label.text = "🔥 x" + str(1 + int(combo / 4)) + " (" + str(combo) + ")"
		combo_label.visible = true
	else:
		combo_label.visible = false

func finish_game() -> void:
	is_active = false
	sfx_player.stream = SoundEffects.get_victory_fanfare_sound()
	sfx_player.play()
	
	var earned_gold = max(25, int(score * 0.4))
	final_score_label.text = "Итоговый счёт: " + str(score)
	reward_label.text = "Награда: +" + str(earned_gold) + " 🪙\nСчастье Юки: 100%! 💖"
	game_over_panel.visible = true

func _on_claim_pressed() -> void:
	var earned_gold = max(25, int(score * 0.4))
	minigame_closed.emit(earned_gold)
	queue_free()

func _on_close_clicked() -> void:
	var earned_gold = max(10, int(score * 0.2)) if score > 0 else 0
	minigame_closed.emit(earned_gold)
	queue_free()
