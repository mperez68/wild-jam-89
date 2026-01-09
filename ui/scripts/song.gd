class_name SongManager extends Node

enum State{ STOPPED, INTRO, LOOP, OUTRO }

@export var song_name: String
@export var intro_base: AudioStream
@export var intro_melody: AudioStream
@export var loop_base: AudioStream
@export var loop_melody: AudioStream
@export var outro_base: AudioStream
@export var outro_melody: AudioStream

@onready var intro: Array[AudioStreamPlayer] = [%IntroBase, %IntroMelody]
@onready var loop: Array[AudioStreamPlayer] = [%LoopBase, %LoopMelody]
@onready var outro: Array[AudioStreamPlayer] = [%OutroBase, %OutroMelody]
@onready var all_tracks: Array[AudioStreamPlayer] = intro + loop + outro

var state: State = State.STOPPED


# ENGINE
func _ready() -> void:
	intro[0].stream = intro_base
	intro[1].stream = intro_melody
	loop[0].stream = loop_base
	loop[1].stream = loop_melody
	outro[0].stream = outro_base
	outro[1].stream = outro_melody


# PUBLIC
func play(force_restart: bool = false):
	if state != State.STOPPED and !force_restart or !loop[0].stream:
		return
	if force_restart:
		stop(false)
	if loop[0].stream:
		for track in intro:
			if track.stream:
				track.play()
		state = State.INTRO
	else:
		_on_intro_finished()

func stop(play_outro: bool = true):
	for track in intro + loop:
		track.stop()
	state = State.STOPPED
	for track in outro:
		if play_outro and outro[0].stream:
			state = State.OUTRO
			track.volume_linear = 1.0
		else:
			track.stop()


# PRIVATE


# SIGNALS
func _on_intro_finished() -> void:
	state = State.LOOP
	for track in loop:
		if track.stream:
			track.play()
	for track in outro:
		if track.stream:
			track.volume_linear = 0.0
			track.play()

func _on_outro_finished() -> void:
	state = State.STOPPED
