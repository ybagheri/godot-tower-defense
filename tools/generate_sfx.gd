## Generates the prototype SFX/music set as 16-bit mono WAVs.
##
## Provenance: all sounds are synthesized by THIS tool from oscillators and
## envelopes - no external samples, no copyright concerns. Rerun to tweak:
##   godot --headless --path . -s tools/generate_sfx.gd
extends SceneTree

const SAMPLE_RATE := 22050
const OUT_DIR := "res://assets/audio/sfx"
const MUSIC_DIR := "res://assets/audio/music"


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(OUT_DIR)
	DirAccess.make_dir_recursive_absolute(MUSIC_DIR)

	write_wav(OUT_DIR + "/build.wav", thump(0.18, 180, 0.5))
	write_wav(OUT_DIR + "/upgrade.wav", sweep(0.25, 300, 700, 0.45))
	write_wav(OUT_DIR + "/sell.wav", sweep(0.22, 600, 250, 0.4))
	write_wav(OUT_DIR + "/death.wav", noise_burst(0.2, 0.5, 900))
	write_wav(OUT_DIR + "/castle_hit.wav", thump(0.35, 90, 0.9))
	write_wav(OUT_DIR + "/victory.wav", melody([392.0, 494.0, 587.0], [0.14, 0.14, 0.3]))
	write_wav(OUT_DIR + "/defeat.wav", melody([392.0, 330.0, 262.0], [0.16, 0.16, 0.36]))
	write_wav(OUT_DIR + "/cast.wav", sweep(0.3, 200, 900, 0.5))

	DirAccess.make_dir_recursive_absolute(MUSIC_DIR)
	write_wav(MUSIC_DIR + "/battle_loop.wav", battle_drone(7.2))
	print("SFX generation complete")
	quit(0)


## Sparse dark drone loop: two detuned low tones + slow pulse.
func battle_drone(duration: float) -> PackedFloat32Array:
	var samples := PackedFloat32Array()
	var count := int(duration * SAMPLE_RATE)
	for i in count:
		var t := float(i) / SAMPLE_RATE
		var wave := 0.22 * sin(TAU * 55.0 * t)
		wave += 0.18 * sin(TAU * 55.7 * t)
		wave += 0.10 * sin(TAU * 110.3 * t)
		var pulse := 1.0 + 0.25 * sin(TAU * 0.5 * t)
		samples.append(wave * pulse * 0.5)
	return samples


# --- Synthesis primitives -----------------------------------------------------

func tone(freq: float, duration: float, amplitude: float) -> PackedFloat32Array:
	var samples := PackedFloat32Array()
	var count := int(duration * SAMPLE_RATE)
	for i in count:
		var t := float(i) / SAMPLE_RATE
		var envelope := pow(1.0 - float(i) / count, 1.6)
		var wave := sin(TAU * freq * t)
		wave += 0.35 * sin(TAU * freq * 2.0 * t)
		samples.append(wave * envelope * amplitude)
	return samples


func thump(duration: float, freq: float, amplitude: float) -> PackedFloat32Array:
	var samples := PackedFloat32Array()
	var count := int(duration * SAMPLE_RATE)
	for i in count:
		var progress := float(i) / count
		var envelope := pow(1.0 - progress, 2.2)
		var pitch := freq * (1.0 - 0.4 * progress)
		samples.append(sin(TAU * pitch * float(i) / SAMPLE_RATE) * envelope * amplitude)
	return samples


func sweep(duration: float, from_freq: float, to_freq: float,
		amplitude: float) -> PackedFloat32Array:
	var samples := PackedFloat32Array()
	var count := int(duration * SAMPLE_RATE)
	var phase := 0.0
	for i in count:
		var progress := float(i) / count
		var envelope := sin(PI * progress)
		var freq := lerpf(from_freq, to_freq, progress)
		phase += TAU * freq / SAMPLE_RATE
		samples.append(sin(phase) * envelope * amplitude)
	return samples


func noise_burst(duration: float, amplitude: float, lowpass: float) -> PackedFloat32Array:
	var samples := PackedFloat32Array()
	var count := int(duration * SAMPLE_RATE)
	var filtered := 0.0
	var alpha := clampf(lowpass / SAMPLE_RATE, 0.0, 1.0)
	for i in count:
		var envelope := pow(1.0 - float(i) / count, 1.8)
		filtered += alpha * (randf() * 2.0 - 1.0) - alpha * filtered
		samples.append(filtered * envelope * amplitude)
	return samples


func melody(freqs: Array, durations: Array) -> PackedFloat32Array:
	var samples := PackedFloat32Array()
	for i in freqs.size():
		samples.append_array(tone(freqs[i], durations[i], 0.42))
	return samples


# --- WAV writing ----------------------------------------------------------------

func write_wav(path: String, samples: PackedFloat32Array) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("Cannot write %s" % path)
		return
	var data_bytes := samples.size() * 2
	file.store_8(0x52); file.store_8(0x49); file.store_8(0x46); file.store_8(0x46) # RIFF
	file.store_32(36 + data_bytes)
	file.store_8(0x57); file.store_8(0x41); file.store_8(0x56); file.store_8(0x45) # WAVE
	file.store_8(0x66); file.store_8(0x6D); file.store_8(0x74); file.store_8(0x20) # fmt 
	file.store_32(16)
	file.store_16(1)              # PCM
	file.store_16(1)              # mono
	file.store_32(SAMPLE_RATE)
	file.store_32(SAMPLE_RATE * 2)
	file.store_16(2)              # block align
	file.store_16(16)             # bits
	file.store_8(0x64); file.store_8(0x61); file.store_8(0x74); file.store_8(0x61) # data
	file.store_32(data_bytes)
	for sample in samples:
		file.store_16(int(clampf(sample, -1.0, 1.0) * 32767.0))
	file.close()
