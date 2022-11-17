extends PanelContainer

var infos : Dictionary = {
	"Title" : "",
	"Artist/s" : "",
	"Album" : "",
	"Filetype" : "",
	"Filepath" : "",
	"Song Duration" : "",
	"Sample Rate" : "",
	"Bitrate" : "",
	"Channels" : ""
}

onready var scroll : ScrollContainer = $HBoxContainer/ScrollContainer
onready var info_space : VBoxContainer = $HBoxContainer/ScrollContainer/HBoxContainer/InfoSpaces

func _ready():
	init_song_infos()


func update() -> void:
	init_song_infos()


func init_song_infos() -> void:
	# retrieving Infos
	infos["Title"] = Tags.get_title(SongLists.current_song)
	infos["Artist/s"] = Tags.get_artist(SongLists.current_song)
	infos["Album"] = Tags.get_album(SongLists.current_song)
	infos["Filetype"] = FormatChecker.get_music_file_extension(SongLists.current_song)
	infos["Filepath"] = SongLists.current_song
	infos["Song Duration"] = TimeFormatter.format_seconds( float( Tags.get_song_duration(SongLists.current_song) ) ) + "min"
	
	var native : Tagging = Tagging.new()
	infos["Sample Rate"] = str( native.GetSongSampleRate(SongLists.current_song) ) + "Hz"
	infos["Bitrate"] = str( native.GetSongBitrate(SongLists.current_song) ) + "kb/s"
	infos["Channels"] = str( native.GetSongChannels(SongLists.current_song) )
	
	# setting Data on Info Spaces
	for i in range(1, info_space.get_child_count()):
		info_space.get_child(i).init_info_space(
			infos.keys()[i - 1],
			infos.values()[i - 1]
		)
