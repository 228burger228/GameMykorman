class_name TextureStudio
extends RefCounted

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
			
			# Белок
			var col = Color(1.0, 1.0, 1.0, 1.0)
			
			# Радужка в центре
			var idx = (x - 128) / 95.0
			var idy = (y - 135) / 105.0
			var iris_dist = sqrt(idx * idx + idy * idy)
			
			if iris_dist <= 1.0:
				# Градиент от темного фиолетового к нежно-малиновому
				var t = clamp((y - 30.0) / 200.0, 0.0, 1.0)
				col = Color(0.2, 0.08, 0.35).lerp(Color(1.0, 0.55, 0.78), t)
				
				# Темный ободок
				if iris_dist > 0.88:
					col = col.lerp(Color(0.1, 0.03, 0.18), 0.7)
				
				# Зрачок
				var p_dist = sqrt(pow((x - 128) / 45.0, 2) + pow((y - 125) / 55.0, 2))
				if p_dist <= 1.0:
					col = Color(0.08, 0.02, 0.15)
				
				# Нижняя светлая дуга
				if y > 150 and iris_dist > 0.6 and iris_dist < 0.85:
					col = col.lerp(Color(1.0, 0.9, 0.98), 0.5)
			
			# Большой блик
			var h1 = sqrt(pow((x - 100) / 26.0, 2) + pow((y - 85) / 32.0, 2))
			if h1 <= 1.0:
				col = Color(1.0, 1.0, 1.0, 1.0)
				
			# Маленький блик
			var h2 = sqrt(pow((x - 165) / 14.0, 2) + pow((y - 165) / 14.0, 2))
			if h2 <= 1.0:
				col = Color(1.0, 1.0, 1.0, 1.0)
			
			img.set_pixel(x, y, col)
			
	return ImageTexture.create_from_image(img)

static func create_face_texture() -> ImageTexture:
	var img = Image.create(256, 256, false, Image.FORMAT_RGBA8)
	var base_skin = Color(1.0, 0.93, 0.89)
	
	for y in range(256):
		for x in range(256):
			var col = base_skin
			
			# Румянец на щечках
			var dl = sqrt(pow((x - 65) / 45.0, 2) + pow((y - 155) / 35.0, 2))
			var dr = sqrt(pow((x - 191) / 45.0, 2) + pow((y - 155) / 35.0, 2))
			
			if dl < 1.0:
				col = col.lerp(Color(1.0, 0.45, 0.6), (1.0 - dl) * 0.6)
			elif dr < 1.0:
				col = col.lerp(Color(1.0, 0.45, 0.6), (1.0 - dr) * 0.6)
				
			# Носик
			var nose_d = sqrt(pow(x - 128, 2) + pow(y - 145, 2))
			if nose_d < 3.0:
				col = Color(0.9, 0.6, 0.55)
				
			img.set_pixel(x, y, col)
			
	return ImageTexture.create_from_image(img)

static func create_sweater_texture(sweater_color: Color = Color(1.0, 0.45, 0.58)) -> ImageTexture:
	var img = Image.create(256, 256, false, Image.FORMAT_RGBA8)
	
	for y in range(256):
		for x in range(256):
			var col = sweater_color
			if (x % 8) < 4:
				col = col.lightened(0.06)
			else:
				col = col.darkened(0.05)
				
			var dx = (x - 128) / 30.0
			var dy = (y - 130) / 30.0
			var heart = pow(dx * dx + dy * dy - 1.0, 3) - dx * dx * dy * dy * dy
			if heart <= 0.0:
				col = Color(1.0, 0.85, 0.35)
				
			img.set_pixel(x, y, col)
			
	return ImageTexture.create_from_image(img)

# Гостиная: Деревянный паркет
static func create_parquet_texture() -> ImageTexture:
	var img = Image.create(256, 256, false, Image.FORMAT_RGBA8)
	var wood_base = Color(0.85, 0.62, 0.42)
	
	for y in range(256):
		for x in range(256):
			var col = wood_base
			if (y % 42) == 0:
				col = Color(0.55, 0.38, 0.22)
			else:
				var row = int(y / 42.0)
				var shift = 64 if (row % 2 == 0) else 0
				if ((x + shift) % 128) == 0:
					col = Color(0.55, 0.38, 0.22)
				else:
					var noise = sin(x * 0.15) * 0.03 + sin(y * 0.05) * 0.02
					col = col.lightened(noise)
			img.set_pixel(x, y, col)
			
	return ImageTexture.create_from_image(img)

# Гостиная: Полосатые пастельные обои
static func create_wallpaper_texture() -> ImageTexture:
	var img = Image.create(256, 256, false, Image.FORMAT_RGBA8)
	var bg = Color(1.0, 0.94, 0.96)
	var stripe = Color(1.0, 0.88, 0.92)
	
	for y in range(256):
		for x in range(256):
			var col = stripe if ((x % 32) < 16) else bg
			var sx = x % 64
			var sy = y % 64
			if (abs(sx - 32) + abs(sy - 32)) < 5:
				col = Color(1.0, 0.7, 0.8)
			img.set_pixel(x, y, col)
			
	return ImageTexture.create_from_image(img)

# Кухня: Шахматная светлая плитка
static func create_kitchen_tile_texture() -> ImageTexture:
	var img = Image.create(256, 256, false, Image.FORMAT_RGBA8)
	var c1 = Color(0.96, 0.97, 0.98)
	var c2 = Color(0.84, 0.92, 0.88)
	var seam = Color(0.72, 0.76, 0.75)
	
	for y in range(256):
		for x in range(256):
			if (x % 64 == 0) or (y % 64 == 0):
				img.set_pixel(x, y, seam)
			else:
				var tx = int(x / 64)
				var ty = int(y / 64)
				var col = c1 if ((tx + ty) % 2 == 0) else c2
				img.set_pixel(x, y, col)
				
	return ImageTexture.create_from_image(img)

# Ванная: Бирюзовый аква-кафель
static func create_bathroom_tile_texture() -> ImageTexture:
	var img = Image.create(256, 256, false, Image.FORMAT_RGBA8)
	var tile_cyan = Color(0.75, 0.92, 0.98)
	var seam = Color(0.60, 0.82, 0.90)
	
	for y in range(256):
		for x in range(256):
			if (x % 32 == 0) or (y % 32 == 0):
				img.set_pixel(x, y, seam)
			else:
				var shimmer = sin(x * 0.2) * cos(y * 0.2) * 0.04
				img.set_pixel(x, y, tile_cyan.lightened(shimmer))
				
	return ImageTexture.create_from_image(img)

# Спальня: Звездные ночные обои
static func create_bedroom_wallpaper_texture() -> ImageTexture:
	var img = Image.create(256, 256, false, Image.FORMAT_RGBA8)
	var night_sky = Color(0.18, 0.16, 0.28)
	var star_gold = Color(1.0, 0.88, 0.45)
	
	for y in range(256):
		for x in range(256):
			var col = night_sky
			var sx = x % 64
			var sy = y % 64
			# Звезды и полумесяцы
			if (sx == 32 and sy == 32) or (sx == 12 and sy == 48) or (sx == 50 and sy == 16):
				col = star_gold
			elif (abs(sx - 32) + abs(sy - 32)) == 1:
				col = star_gold.lightened(0.2)
			img.set_pixel(x, y, col)
			
	return ImageTexture.create_from_image(img)
