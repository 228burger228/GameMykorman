class_name WardrobeDialog
extends Control

signal item_equipped(category: String, item_id: String)
signal wardrobe_closed(updated_data: Dictionary)

const SoundEffects = preload("res://scripts/sound_effects.gd")

var current_tab: String = "sweaters"
var save_data: Dictionary = {}

@onready var gold_label: Label = $Modal/VBox/Header/GoldBox/HBox/GoldLabel
@onready var tab_sweaters: Button = $Modal/VBox/Tabs/SweatersTab
@onready var tab_hair: Button = $Modal/VBox/Tabs/HairTab
@onready var tab_acc: Button = $Modal/VBox/Tabs/AccTab
@onready var items_container: VBoxContainer = $Modal/VBox/Scroll/ItemsList
@onready var close_btn: Button = $Modal/VBox/Header/CloseBtn
@onready var sfx_player: AudioStreamPlayer = $SFXPlayer

const CATALOG = {
	"sweaters": [
		{"id": "sweater_strawberry", "name": "🍓 Клубничный свитер", "price": 0, "desc": "Теплый розовый с золотым сердечком"},
		{"id": "sweater_mint", "name": "🍃 Изумрудная мята", "price": 150, "desc": "Свежий зеленый с клевером на удачу"},
		{"id": "sweater_cyber", "name": "🌌 Кибер-индиго", "price": 220, "desc": "Космический синий с неоновой звездой"},
		{"id": "sweater_honey", "name": "🍯 Медовый янтарь", "price": 300, "desc": "Янтарный свитер с кошачьей лапкой"}
	],
	"hair": [
		{"id": "hair_sakura", "name": "🌸 Нежная сакура", "price": 0, "desc": "Классические шелковистые розовые хвостики"},
		{"id": "hair_azure", "name": "🌊 Лазурный океан", "price": 180, "desc": "Яркие бирюзово-голубые локоны"},
		{"id": "hair_golden", "name": "🌾 Золотая пшеница", "price": 250, "desc": "Благородный золотой блеск"},
		{"id": "hair_lavender", "name": "🔮 Магическая лаванда", "price": 280, "desc": "Загадочный фиалковый градиент"}
	],
	"accessories": [
		{"id": "acc_none", "name": "❌ Без аксессуаров", "price": 0, "desc": "Естественный чистый образ"},
		{"id": "acc_bow", "name": "🎀 Красный бант", "price": 120, "desc": "Праздничный алый бант на макушке"},
		{"id": "acc_glasses", "name": "👓 Стильные очки", "price": 160, "desc": "Золотая круглая оправа для интеллигентного взгляда"},
		{"id": "acc_star", "name": "⭐ Золотая звёздочка", "price": 240, "desc": "Сияющая заколка на челке"},
		{"id": "acc_neko", "name": "🐱 Неко-ушки", "price": 200, "desc": "Игривые кошачьи ушки"}
	]
}

func init_wardrobe(initial_save_data: Dictionary) -> void:
	save_data = initial_save_data.duplicate(true)
	if not save_data.has("unlocked_items"):
		save_data["unlocked_items"] = ["sweater_strawberry", "hair_sakura", "acc_none"]

func _ready() -> void:
	tab_sweaters.pressed.connect(func(): switch_tab("sweaters"))
	tab_hair.pressed.connect(func(): switch_tab("hair"))
	tab_acc.pressed.connect(func(): switch_tab("accessories"))
	close_btn.pressed.connect(_on_close_pressed)
	refresh_ui()

func switch_tab(tab_name: String) -> void:
	current_tab = tab_name
	refresh_ui()

func refresh_ui() -> void:
	gold_label.text = str(save_data.get("gold", 0))

	# Очистка списка
	for child in items_container.get_children():
		child.queue_free()

	var list = CATALOG.get(current_tab, [])
	var equipped_key = ""
	match current_tab:
		"sweaters": equipped_key = "equipped_sweater"
		"hair": equipped_key = "equipped_hair"
		"accessories": equipped_key = "equipped_acc"

	var current_equipped = save_data.get(equipped_key, "")

	for item in list:
		var item_id = item["id"]
		var is_unlocked = (item["price"] == 0) or (item_id in save_data.get("unlocked_items", []))
		var is_equipped = (item_id == current_equipped)

		var card = PanelContainer.new()
		var card_style = StyleBoxFlat.new()
		card_style.bg_color = Color(0.18, 0.15, 0.30, 0.85) if not is_equipped else Color(0.28, 0.22, 0.45, 0.95)
		card_style.set_corner_radius_all(10)
		card_style.border_width_left = 1
		card_style.border_width_top = 1
		card_style.border_width_right = 1
		card_style.border_width_bottom = 1
		card_style.border_color = Color(1, 0.8, 0.4, 0.9) if is_equipped else Color(1, 1, 1, 0.15)
		card.add_theme_stylebox_override("panel", card_style)

		var hbox = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 10)
		card.add_child(hbox)

		# Текстовое описание
		var vbox = VBoxContainer.new()
		vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var title = Label.new()
		title.text = item["name"]
		title.add_theme_font_size_override("font_size", 13)
		vbox.add_child(title)

		var desc = Label.new()
		desc.text = item["desc"]
		desc.add_theme_color_override("font_color", Color(0.75, 0.75, 0.85))
		desc.add_theme_font_size_override("font_size", 10)
		vbox.add_child(desc)
		hbox.add_child(vbox)

		# Кнопка действия
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(90, 32)
		btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER

		if is_equipped:
			btn.text = "✓ Надето"
			btn.disabled = true
		elif is_unlocked:
			btn.text = "Надеть"
			btn.pressed.connect(func(): equip_item(current_tab, item_id))
		else:
			var price = item["price"]
			btn.text = str(price) + " 🪙"
			if save_data.get("gold", 0) < price:
				btn.disabled = true
			else:
				btn.pressed.connect(func(): buy_and_equip_item(current_tab, item_id, price))

		hbox.add_child(btn)
		items_container.add_child(card)

func equip_item(category: String, item_id: String) -> void:
	match category:
		"sweaters": save_data["equipped_sweater"] = item_id
		"hair": save_data["equipped_hair"] = item_id
		"accessories": save_data["equipped_acc"] = item_id

	sfx_player.stream = SoundEffects.get_dressup_sparkle_sound()
	sfx_player.play()
	item_equipped.emit(category, item_id)
	refresh_ui()

func buy_and_equip_item(category: String, item_id: String, price: int) -> void:
	var current_gold = save_data.get("gold", 0)
	if current_gold >= price:
		save_data["gold"] = current_gold - price
		var unlocked = save_data.get("unlocked_items", [])
		if not item_id in unlocked:
			unlocked.append(item_id)
		save_data["unlocked_items"] = unlocked
		equip_item(category, item_id)

func _on_close_pressed() -> void:
	wardrobe_closed.emit(save_data)
	queue_free()
