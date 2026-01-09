extends Node

var songs: Dictionary[String, SongManager]


# ENGINE
func _ready() -> void:
	for child in get_children():
		if child is SongManager:
			songs[child.name if child.song_name.is_empty() else child.song_name] = child


# PUBLIC
func play(song: String):
	if !songs.keys().has(song):
		printerr("song %s does not exist!" % song)
		return
	songs[song].play()


# PRIVATE


# SIGNALS
