extends Node

const _BLOW_SOUNDS : Array[AudioStream] = [
	preload("res://common/blow.wav"), 
	preload("res://common/blow1.wav"),
]
const _POP_SOUNDS : Array[AudioStream] = [
	preload("res://common/bubble_pop.wav"),
	preload("res://common/bubble_pop1.wav"),
	preload("res://common/bubble_pop3.wav"),
	preload("res://common/bubble_pop4.wav"),
	preload("res://common/bubble_pop5.wav"),
]
const _BUMP_SOUNDS : Array[AudioStream] = [
	preload("res://common/bump2.wav"),
]
const _POLE_SOUNDS : Array[AudioStream] = _BUMP_SOUNDS
const _SCORE_SOUNDS : Array[AudioStream] = [
	preload("res://common/score.wav"),
]
const _GOBLIN_SOUNDS : Array[AudioStream] = [
	preload("res://common/goblin_sound.wav"),
]

func play_blow_sound() -> void:
	_play($BlowSoundPlayer, _BLOW_SOUNDS)


func play_pop_sound() -> void:
	_play($PopSoundPlayer, _POP_SOUNDS)


func play_bump_sound() -> void:
	_play($BumpSoundPlayer, _BUMP_SOUNDS)


func play_pole_sound() -> void:
	_play($PoleSoundPlayer, _POLE_SOUNDS)


func play_score_sound() -> void:
	_play($ScoreSoundPlayer, _SCORE_SOUNDS)


func play_goblin_sound() -> void:
	_play($GoblinSoundPlayer, _GOBLIN_SOUNDS)


func _play(player : AudioStreamPlayer, array : Array[AudioStream]) -> void:
	player.stream = array.pick_random()
	player.pitch_scale = randfn(1.0, 0.05)
	player.play()
