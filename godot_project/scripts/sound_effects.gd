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
