class_name TextureStudio
extends RefCounted

# Глаза аниме: глубокий сапфирово-фиалковый градиент с кристальными бликами
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
			
			# Мягкий белок глаза с легким объемом сверху
			var shadow_t = clamp((y - 30.0) / 100.0, 0.0, 1.0)
			var col = Color(0.92, 0.93, 0.96).lerp(Color(1.0, 1.0, 1.0), shadow_t)
			
			# Радужка
			var idx = (x - 128) / 95.0
			var idy = (y - 135) / 105.0
			var iris_dist = sqrt(idx * idx + idy * idy)
			
			if iris_dist <= 1.0:
				# Благородный сапфирово-индиго градиент (глубокий и чистый, без яда)
				var t = clamp((y - 40.0) / 190.0, 0.0, 1.0)
				col = Color(0.12, 0.14, 0.32).lerp(Color(0.42, 0.48, 0.82), t)
				
				# Тонкий аккуратный лимб
				if iris_dist > 0.90:
					col = col.lerp(Color(0.08, 0.09, 0.20), 0.75)
				
				# Зрачок
				var p_dist = sqrt(pow((x - 128) / 42.0, 2) + pow((y - 125) / 52.0, 2))
				if p_dist <= 1.0:
					col = Color(0.06, 0.07, 0.16)
				
				# Мягкая нижняя дуга подсветки радужки
				if y > 152 and iris_dist > 0.58 and iris_dist < 0.85:
					col = col.lerp(Color(0.70, 0.80, 0.98), 0.45)
			
			# Главный чистый блик
			var h1 = sqrt(pow((x - 100) / 24.0, 2) + pow((y - 88) / 30.0, 2))
			if h1 <= 1.0:
				col = Color(1.0, 1.0, 1.0, 1.0)
				
			# Вторичный микроблик
			var h2 = sqrt(pow((x - 162) / 13.0, 2) + pow((y - 165) / 13.0, 2))
			if h2 <= 1.0:
				col = Color(1.0, 1.0, 1.0, 0.9)
			
			img.set_pixel(x, y, col)
			
	return ImageTexture.create_from_image(img)

# Лицо: чистый фарфор с естественным нежным румянцем (без кислотных пятен)
static func create_face_texture() -> ImageTexture:
	var img = Image.create(256, 256, false, Image.FORMAT_RGBA8)
	var base_skin = Color(0.99, 0.95, 0.93)
	
	for y in range(256):
		for x in range(256):
			var col = base_skin
			
			# Деликатный акварельный румянец
			var dl = sqrt(pow((x - 70) / 46.0, 2) + pow((y - 156) / 32.0, 2))
			var dr = sqrt(pow((x - 186) / 46.0, 2) + pow((y - 156) / 32.0, 2))
			
			if dl < 1.0:
				col = col.lerp(Color(0.98, 0.62, 0.68), (1.0 - dl) * 0.45)
			elif dr < 1.0:
				col = col.lerp(Color(0.98, 0.62, 0.68), (1.0 - dr) * 0.45)
				
			# Мягкая тень носика
			var nose_d = sqrt(pow(x - 128, 2) + pow(y - 146, 2))
			if nose_d < 3.2:
				col = Color(0.92, 0.72, 0.70)
				
			img.set_pixel(x, y, col)
			
	return ImageTexture.create_from_image(img)

# Свитер: мягкая пудровая лаванда/кашемир с аккуратным рельефом вязки
static func create_sweater_texture(sweater_color: Color = Color(0.85, 0.58, 0.68)) -> ImageTexture:
	var img = Image.create(256, 256, false, Image.FORMAT_RGBA8)
	
	for y in range(256):
		for x in range(256):
			var col = sweater_color
			# Тонкие мягкие бороздки трикотажа
			if (x % 8) < 4:
				col = col.lightened(0.04)
			else:
				col = col.darkened(0.03)
				
			# Деликатное золотистое тиснение сердечка
			var dx = (x - 128) / 30.0
			var dy = (y - 130) / 30.0
			var heart = pow(dx * dx + dy * dy - 1.0, 3) - dx * dx * dy * dy * dy
			if heart <= 0.0:
				col = Color(0.95, 0.82, 0.55)
				
			img.set_pixel(x, y, col)
			
	return ImageTexture.create_from_image(img)

# Гостиная: Скандинавский матовый дуб/ясень (без ядовитой рыжины)
static func create_parquet_texture() -> ImageTexture:
	var img = Image.create(256, 256, false, Image.FORMAT_RGBA8)
	var wood_base = Color(0.85, 0.78, 0.70)
	var seam = Color(0.68, 0.62, 0.55)
	
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
					# Мягкий естественный градиент волокон дерева
					var grain = sin(x * 0.12) * 0.02 + sin(y * 0.04) * 0.015
					col = col.lightened(grain)
			img.set_pixel(x, y, col)
			
	return ImageTexture.create_from_image(img)

# Гостиная: Тёплый молочно-льняной японский минимализм (без кислотных розовых полос и точек!)
static func create_wallpaper_texture() -> ImageTexture:
	var img = Image.create(256, 256, false, Image.FORMAT_RGBA8)
	var linen_base = Color(0.96, 0.94, 0.92)
	var subtle_weave = Color(0.93, 0.91, 0.89)
	
	for y in range(256):
		for x in range(256):
			# Мягкая текстильная текстура льна без режущих глаз контрастов
			var weave = ((x + y) % 4 == 0)
			var col = subtle_weave if weave else linen_base
			var noise = sin(x * 0.3) * cos(y * 0.3) * 0.01
			col = col.lightened(noise)
			img.set_pixel(x, y, col)
			
	return ImageTexture.create_from_image(img)

# Кухня: Матовая светлая керамическая плитка и теплый штрих
static func create_kitchen_tile_texture() -> ImageTexture:
	var img = Image.create(256, 256, false, Image.FORMAT_RGBA8)
	var c1 = Color(0.95, 0.94, 0.92)
	var c2 = Color(0.90, 0.89, 0.87)
	var seam = Color(0.78, 0.76, 0.74)
	
	for y in range(256):
		for x in range(256):
			if (x % 64 == 0) or (y % 64 == 0):
				img.set_pixel(x, y, seam)
			else:
				var tx = int(x / 64)
				var ty = int(y / 64)
				var col = c1 if ((tx + ty) % 2 == 0) else c2
				var subtle = sin(x * 0.1) * 0.01
				img.set_pixel(x, y, col.lightened(subtle))
				
	return ImageTexture.create_from_image(img)

# Ванная: Пастельный мягкий селадон/шалфей (успокаивающий спа-оттенок вместо едкой бирюзы)
static func create_bathroom_tile_texture() -> ImageTexture:
	var img = Image.create(256, 256, false, Image.FORMAT_RGBA8)
	var tile_sage = Color(0.83, 0.89, 0.87)
	var seam = Color(0.70, 0.77, 0.74)
	
	for y in range(256):
		for x in range(256):
			if (x % 32 == 0) or (y % 32 == 0):
				img.set_pixel(x, y, seam)
			else:
				var shimmer = sin(x * 0.15) * cos(y * 0.15) * 0.02
				img.set_pixel(x, y, tile_sage.lightened(shimmer))
				
	return ImageTexture.create_from_image(img)

# Спальня: Уютный глубокий индиго с мягким звёздным микро-узором
static func create_bedroom_wallpaper_texture() -> ImageTexture:
	var img = Image.create(256, 256, false, Image.FORMAT_RGBA8)
	var night_sky = Color(0.11, 0.12, 0.18)
	var star_soft = Color(0.75, 0.72, 0.58)
	
	for y in range(256):
		for x in range(256):
			var col = night_sky
			var sx = x % 64
			var sy = y % 64
			# Тонкие деликатные звездочки
			if (sx == 32 and sy == 32) or (sx == 10 and sy == 48):
				col = star_soft
			img.set_pixel(x, y, col)
			
	return ImageTexture.create_from_image(img)
