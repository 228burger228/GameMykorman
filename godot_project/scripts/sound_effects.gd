class_name SoundEffects
extends RefCounted

static func create_wav_sample(sample_rate: int, duration_sec: float, generator_func: Callable) -> AudioStreamWAV:
	var wav = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = sample_rate
	wav.stereo = false
	
	var num_samples = int(sample_rate * duration_sec)
	var byte_array = PackedByteArray()
	byte_array.resize(num_samples * 2)
	
	for i in range(num_samples):
		var t = float(i) / sample_rate
		var val = clampf(generator_func.call(t, duration_sec), -1.0, 1.0)
		var sample_16 = int(val * 32767.0)
		byte_array.encode_s16(i * 2, sample_16)
		
	wav.data = byte_array
	return wav

# Пощечина Тома: глухой мультяшный шлепок
static func get_slap_sound() -> AudioStreamWAV:
	return create_wav_sample(22050, 0.22, func(t, _dur):
		var env = exp(-t * 22.0)
		var freq = 160.0 * exp(-t * 18.0)
		var body = sin(t * freq * TAU) * 0.7
		var noise = (randf() * 2.0 - 1.0) * 0.35 * exp(-t * 35.0)
		return (body + noise) * env
	)

# Мурлыкание: глубокая бархатная вибрация
static func get_purr_sound() -> AudioStreamWAV:
	return create_wav_sample(22050, 0.35, func(t, dur):
		var env = sin(t / dur * PI)
		var lfo = 1.0 + 0.3 * sin(t * 22.0 * TAU)
		return sin(t * 95.0 * TAU) * lfo * env * 0.6
	)

# Смех: нежный перелив колокольчиков
static func get_giggle_sound() -> AudioStreamWAV:
	return create_wav_sample(22050, 0.35, func(t, _dur):
		var step = int(t * 10.0)
		var freqs = [523.25, 659.25, 783.99, 1046.50]
		var f = freqs[min(step, freqs.size() - 1)]
		var env = exp(-fmod(t, 0.09) * 20.0)
		return sin(t * f * TAU) * env * 0.5
	)

# Хруст еды / откусывание
static func get_crunch_sound() -> AudioStreamWAV:
	return create_wav_sample(22050, 0.18, func(t, _dur):
		var env = exp(-t * 28.0)
		var f = 580.0 if t < 0.08 else 880.0
		return sin(t * f * TAU) * env * 0.5
	)

# Золотая монетка
static func get_coin_sound() -> AudioStreamWAV:
	return create_wav_sample(22050, 0.4, func(t, _dur):
		var f = 987.77 if t < 0.08 else 1318.51
		var env = exp(-t * 6.0)
		return sin(t * f * TAU) * env * 0.6
	)

# Щелчок выключателя света (Лампа / Торшер)
static func get_switch_sound() -> AudioStreamWAV:
	return create_wav_sample(22050, 0.08, func(t, _dur):
		var env = exp(-t * 60.0)
		var click = sin(t * 1400.0 * TAU) + (randf() * 2.0 - 1.0) * 0.4
		return click * env * 0.7
	)

# Журчание воды / Душ в ванной
static func get_water_sound() -> AudioStreamWAV:
	return create_wav_sample(22050, 1.2, func(t, dur):
		var env = sin(t / dur * PI)
		var noise = (randf() * 2.0 - 1.0) * 0.45
		var low_rumble = sin(t * 120.0 * TAU) * 0.2
		return (noise + low_rumble) * env * 0.65
	)

# Мыльный пузырь (хлопок)
static func get_bubble_sound() -> AudioStreamWAV:
	return create_wav_sample(22050, 0.14, func(t, _dur):
		var f = 400.0 + t * 3200.0
		var env = exp(-t * 30.0)
		return sin(t * f * TAU) * env * 0.6
	)

# Острый перец чили (шипение / свист огня)
static func get_spicy_sound() -> AudioStreamWAV:
	return create_wav_sample(22050, 0.65, func(t, dur):
		var env = sin(t / dur * PI)
		var sizzle = (randf() * 2.0 - 1.0) * 0.4
		var f = 300.0 + 800.0 * sin(t * 15.0)
		var tone = sin(t * f * TAU) * 0.35
		return (sizzle + tone) * env * 0.75
	)

# Зевание / сонный вздох
static func get_yawn_sound() -> AudioStreamWAV:
	return create_wav_sample(22050, 0.8, func(t, dur):
		var env = sin(t / dur * PI)
		var f = 550.0 - 220.0 * (t / dur)
		return sin(t * f * TAU) * env * 0.4
	)

# Чиптюн-музыка из ретро-консоли / радио
static func get_retro_tune_sound() -> AudioStreamWAV:
	return create_wav_sample(22050, 2.4, func(t, _dur):
		var notes = [261.63, 329.63, 392.00, 523.25, 392.00, 329.63, 440.00, 493.88]
		var idx = int(t * 3.33) % notes.size()
		var f = notes[idx]
		# Меандр (Square wave)
		var square = 1.0 if fmod(t * f, 1.0) > 0.5 else -1.0
		var sub = sin(t * (f * 0.5) * TAU) * 0.3
		return (square * 0.3 + sub) * 0.35
	)

# Чиби-лепет / голос персонажа (Talking Yuki voice chirp)
static func get_chibi_talk_sound(pitch_shift: float = 1.0) -> AudioStreamWAV:
	return create_wav_sample(22050, 0.42, func(t, dur):
		var step = int(t * 18.0)
		var freqs = [659.25, 783.99, 880.00, 1046.50, 987.77, 880.00, 1174.66]
		var base_f = freqs[step % freqs.size()] * pitch_shift
		var vibrato = sin(t * 30.0) * 15.0
		var f = base_f + vibrato
		var env = sin(t / dur * PI) * (0.5 + 0.5 * sin(t * 36.0 * TAU))
		var vocal_formant = sin(t * f * TAU) * 0.5 + sin(t * f * 2.0 * TAU) * 0.3 + sin(t * f * 3.0 * TAU) * 0.2
		return vocal_formant * env * 0.65
	)

# Звук подбора сладкого бонуса в мини-игре
static func get_item_pickup_sound() -> AudioStreamWAV:
	return create_wav_sample(22050, 0.25, func(t, dur):
		var env = exp(-t * 12.0)
		var f = 880.0 + (t / dur) * 1200.0
		var wave = sin(t * f * TAU) * 0.7 + sin(t * f * 2.0 * TAU) * 0.3
		return wave * env * 0.6
	)

# Звук ошибки / попадания жгучего чили в корзину
static func get_hazard_hit_sound() -> AudioStreamWAV:
	return create_wav_sample(22050, 0.35, func(t, _dur):
		var env = exp(-t * 10.0)
		var f = 220.0 * exp(-t * 8.0)
		var buzz = (1.0 if fmod(t * f, 1.0) > 0.5 else -1.0) * 0.6
		var noise = (randf() * 2.0 - 1.0) * 0.4
		return (buzz + noise) * env * 0.7
	)

# Победный фанфар мини-игры
static func get_victory_fanfare_sound() -> AudioStreamWAV:
	return create_wav_sample(22050, 1.2, func(t, _dur):
		var notes = [523.25, 659.25, 783.99, 1046.50]
		var idx = min(int(t * 5.0), notes.size() - 1)
		var f = notes[idx]
		var env = exp(-fmod(t, 0.2) * 8.0) if t < 0.6 else exp(-(t - 0.6) * 4.0)
		var square = 1.0 if fmod(t * f, 1.0) > 0.5 else -1.0
		return (square * 0.4 + sin(t * f * TAU) * 0.4) * env * 0.65
	)

# Экипировка в гардеробе (магический блеск)
static func get_dressup_sparkle_sound() -> AudioStreamWAV:
	return create_wav_sample(22050, 0.32, func(t, dur):
		var env = exp(-t * 9.0)
		var f = 1200.0 + sin(t * 40.0) * 600.0
		var bell = sin(t * f * TAU) * 0.75
		return bell * env * 0.5
	)
