class_name SaveManager
extends RefCounted

const SAVE_PATH = "user://yuki_save.json"

static func get_default_data() -> Dictionary:
	return {
		"gold": 350,
		"hunger": 85.0,
		"hygiene": 90.0,
		"energy": 80.0,
		"mood": 95.0,
		"high_score": 0,
		"unlocked_items": [
			"sweater_strawberry",
			"hair_sakura",
			"acc_none"
		],
		"equipped_sweater": "sweater_strawberry",
		"equipped_hair": "hair_sakura",
		"equipped_acc": "acc_none"
	}

static func save_game(data: Dictionary) -> bool:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if not file:
		push_error("SaveManager: Failed to open save file for writing: " + SAVE_PATH)
		return false
	var json_str = JSON.stringify(data, "\t")
	file.store_string(json_str)
	file.close()
	return true

static func load_game() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return get_default_data()
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return get_default_data()
	var content = file.get_as_text()
	file.close()
	var parsed = JSON.parse_string(content)
	if typeof(parsed) == TYPE_DICTIONARY:
		var default_data = get_default_data()
		# Дополнить недостающие ключи из дефолтных
		for k in default_data.keys():
			if not parsed.has(k):
				parsed[k] = default_data[k]
		return parsed
	return get_default_data()
