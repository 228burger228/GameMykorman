class_name TextureStudio
extends RefCounted

# Глаза аниме: глубокий сапфирово-фиалковый градиент с кристальными бликами и яркой бирюзовой радужкой
static func create_anime_eye_texture() -> ImageTexture:
	var img = Image.create(256, 256, false, Image.FORMAT_RGBA8)
	
	for y in range(256):
		for x in range(256):
			var dx = (x - 128) / 128.0
			var dy = (y - 128) / 128.0
			var dist = sqrt(dx * dx + dy * dy)
			
			if dist > 1.0:
				img.set_pixel(x, y, Color(0, 0, 0, 0))
				continue
			
			# Белок глаза с легкой нежно-розовой тенью сверху
			var shadow_t = clamp((y - 30.0) / 100.0, 0.0, 1.0)
			var col = Color(0.95, 0.94, 0.98).lerp(Color(1.0, 1.0, 1.0), shadow_t)
			
			# Радужка
			var idx = (x - 128) / 95.0
			var idy = (y - 135) / 105.0
			var iris_dist = sqrt(idx * idx + idy * idy)
			
			if iris_dist <= 1.0:
				# Сочный градиент от глубокого сапфира к сияющей фиалке и лазури
				var t = clamp((y - 40.0) / 190.0, 0.0, 1.0)
				col = Color(0.10, 0.15, 0.48).lerp(Color(0.35, 0.58, 0.98), t)
				
				# Тонкий аккуратный лимб
				if iris_dist > 0.90:
					col = col.lerp(Color(0.06, 0.08, 0.30), 0.85)
				
				# Зрачок
				var p_dist = sqrt(pow((x - 128) / 42.0, 2) + pow((y - 125) / 52.0, 2))
				if p_dist <= 1.0:
					col = Color(0.04, 0.05, 0.22)
				
				# Яркая нижняя дуга подсветки радужки (аниме glow)
				if y > 150 and iris_dist > 0.55 and iris_dist < 0.88:
					col = col.lerp(Color(0.55, 0.88, 1.0), 0.70)
			
			# Главный кристальный блик
			var h1 = sqrt(pow((x - 100) / 24.0, 2) + pow((y - 88) / 30.0, 2))
			if h1 <= 1.0:
				col = Color(1.0, 1.0, 1.0, 1.0)
				
			# Вторичный блик
			var h2 = sqrt(pow((x - 162) / 14.0, 2) + pow((y - 165) / 14.0, 2))
			if h2 <= 1.0:
				col = Color(1.0, 1.0, 1.0, 0.95)

			# Искорка-звездочка
			var h3 = sqrt(pow((x - 150) / 7.0, 2) + pow((y - 95) / 7.0, 2))
			if h3 <= 1.0:
				col = Color(1.0, 1.0, 1.0, 0.9)
			
			img.set_pixel(x, y, col)
			
	return ImageTexture.create_from_image(img)

# Лицо: теплый фарфор со свежим румянцем и нежными губками
static func create_face_texture() -> ImageTexture:
	var img = Image.create(256, 256, false, Image.FORMAT_RGBA8)
	var base_skin = Color(1.0, 0.95, 0.93)
	
	for y in range(256):
		for x in range(256):
			var col = base_skin
			
			# Сочный милый персиково-розовый румянец
			var dl = sqrt(pow((x - 68) / 46.0, 2) + pow((y - 156) / 30.0, 2))
			var dr = sqrt(pow((x - 188) / 46.0, 2) + pow((y - 156) / 30.0, 2))
			
			if dl < 1.0:
				col = col.lerp(Color(1.0, 0.55, 0.65), (1.0 - dl) * 0.65)
			elif dr < 1.0:
				col = col.lerp(Color(1.0, 0.55, 0.65), (1.0 - dr) * 0.65)
				
			# Тень носика
			var nose_d = sqrt(pow(x - 128, 2) + pow(y - 146, 2))
			if nose_d < 3.2:
				col = Color(0.96, 0.70, 0.68)
				
			img.set_pixel(x, y, col)
			
	return ImageTexture.create_from_image(img)

# Свитер: яркий клубнично-розовый вязаный джемпер с золотым сердечком
static func create_sweater_texture(sweater_color: Color = Color(0.96, 0.48, 0.64)) -> ImageTexture:
	var img = Image.create(256, 256, false, Image.FORMAT_RGBA8)
	
	for y in range(256):
		for x in range(256):
			var col = sweater_color
			# Рельефная уютная вязка
			if (x % 8) < 4:
				col = col.lightened(0.06)
			else:
				col = col.darkened(0.05)
				
			# Золотистое сияющее сердечко по центру
			var dx = (x - 128) / 32.0
			var dy = (y - 130) / 32.0
			var heart = pow(dx * dx + dy * dy - 1.0, 3) - dx * dx * dy * dy * dy
			if heart <= 0.0:
				col = Color(1.0, 0.85, 0.35)
				
			img.set_pixel(x, y, col)
			
	return ImageTexture.create_from_image(img)

# Гостиная: Тёплый янтарный медовый дубовый паркет (живой и сочный, без серости)
static func create_parquet_texture() -> ImageTexture:
	var img = Image.create(256, 256, false, Image.FORMAT_RGBA8)
	var wood_base = Color(0.92, 0.74, 0.48)
	var wood_alt = Color(0.88, 0.68, 0.42)
	var seam = Color(0.68, 0.48, 0.28)
	
	for y in range(256):
		for x in range(256):
			var col = wood_base
			if (y % 48) == 0:
				col = seam
			else:
				var row = int(y / 48.0)
				var shift = 64 if (row % 2 == 0) else 0
				if ((x + shift) % 128) == 0:
					col = seam
				else:
					if (row % 2 == 1):
						col = wood_alt
					# Теплые волокна древесины
					var grain = sin(x * 0.15) * 0.035 + sin(y * 0.05) * 0.02
					col = col.lightened(grain)
			img.set_pixel(x, y, col)
			
	return ImageTexture.create_from_image(img)

# Гостиная: Уютные персиково-кремовые обои с теплыми полосами и сакурой
static func create_wallpaper_texture() -> ImageTexture:
	var img = Image.create(256, 256, false, Image.FORMAT_RGBA8)
	var cream_base = Color(1.0, 0.96, 0.91)
	var peach_stripe = Color(0.99, 0.88, 0.82)
	var gold_accent = Color(1.0, 0.82, 0.65)
	
	for y in range(256):
		for x in range(256):
			# Чередование мягких полос
			var is_stripe = (int(x / 32.0) % 2 == 0)
			var col = peach_stripe if is_stripe else cream_base
			
			# Тонкая золотистая полоска-разделитель
			if (x % 32 == 0):
				col = gold_accent
				
			img.set_pixel(x, y, col)
			
	return ImageTexture.create_from_image(img)

# Кухня: Солнечная теплая терракотово-абрикосовая плитка
static func create_kitchen_tile_texture() -> ImageTexture:
	var img = Image.create(256, 256, false, Image.FORMAT_RGBA8)
	var c1 = Color(1.0, 0.98, 0.94)
	var c2 = Color(0.99, 0.84, 0.72)
	var seam = Color(0.85, 0.70, 0.58)
	
	for y in range(256):
		for x in range(256):
			if (x % 64 == 0) or (y % 64 == 0):
				img.set_pixel(x, y, seam)
			else:
				var tx = int(x / 64)
				var ty = int(y / 64)
				var col = c1 if ((tx + ty) % 2 == 0) else c2
				var subtle = sin(x * 0.12) * 0.015
				img.set_pixel(x, y, col.lightened(subtle))
				
	return ImageTexture.create_from_image(img)

# Ванная: Сияющая лазурно-бирюзовая спа-мозаика с кристальным блеском
static func create_bathroom_tile_texture() -> ImageTexture:
	var img = Image.create(256, 256, false, Image.FORMAT_RGBA8)
	var tile_aqua = Color(0.42, 0.82, 0.90)
	var tile_light = Color(0.65, 0.92, 0.96)
	var seam = Color(0.92, 0.98, 1.0)
	
	for y in range(256):
		for x in range(256):
			if (x % 32 == 0) or (y % 32 == 0):
				img.set_pixel(x, y, seam)
			else:
				var bx = int(x / 32)
				var by = int(y / 32)
				var col = tile_light if ((bx + by) % 2 == 0) else tile_aqua
				var shimmer = sin(x * 0.2) * cos(y * 0.2) * 0.04
				img.set_pixel(x, y, col.lightened(shimmer))
				
	return ImageTexture.create_from_image(img)

# Спальня: Сказочный индиго-фиалковый закат с сияющими золотыми звездами
static func create_bedroom_wallpaper_texture() -> ImageTexture:
	var img = Image.create(256, 256, false, Image.FORMAT_RGBA8)
	var night_sky = Color(0.18, 0.16, 0.35)
	var nebula_violet = Color(0.28, 0.22, 0.48)
	var star_gold = Color(1.0, 0.88, 0.42)
	
	for y in range(256):
		for x in range(256):
			var t = y / 256.0
			var col = night_sky.lerp(nebula_violet, t)
			
			var sx = x % 64
			var sy = y % 64
			# Сияющие золотистые звезды
			if (sx == 32 and sy == 32) or (sx == 12 and sy == 50) or (sx == 52 and sy == 16):
				col = star_gold
			elif (abs(sx - 32) + abs(sy - 32) == 1):
				col = col.lerp(star_gold, 0.4)
				
			img.set_pixel(x, y, col)
			
	return ImageTexture.create_from_image(img)
