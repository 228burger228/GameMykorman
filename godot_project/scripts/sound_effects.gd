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
	return create_wav_sample(22050, 0.22, func(t, dur):
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

# Смех: нежный колокольчик
static func get_giggle_sound() -> AudioStreamWAV:
	return create_wav_sample(22050, 0.35, func(t, dur):
		var step = int(t * 10.0)
		var freqs = [523.25, 659.25, 783.99, 1046.50]
		var f = freqs[min(step, freqs.size() - 1)]
		var env = exp(-fmod(t, 0.09) * 20.0)
		return sin(t * f * TAU) * env * 0.5
	)

# Хруст еды
static func get_crunch_sound() -> AudioStreamWAV:
	return create_wav_sample(22050, 0.18, func(t, dur):
		var env = exp(-t * 28.0)
		var f = 580.0 if t < 0.08 else 880.0
		return sin(t * f * TAU) * env * 0.5
	)

# Золотая монетка
static func get_coin_sound() -> AudioStreamWAV:
	return create_wav_sample(22050, 0.4, func(t, dur):
		var f = 987.77 if t < 0.08 else 1318.51
		var env = exp(-t * 6.0)
		return sin(t * f * TAU) * env * 0.6
	)
