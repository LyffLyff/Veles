extends PanelContainer


#NODES
onready var Scroll : ScrollContainer = $HBoxContainer/ScrollContainer
onready var InfoSpace : VBoxContainer = $HBoxContainer/ScrollContainer/HBoxContainer/InfoSpaces

#VARIABLES
var Infos : Dictionary = {
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
  
func _ready():
	InitSongInfos()


func Update() -> void:
	InitSongInfos()


func InitSongInfos() -> void:
	#Retrieving Infos
	Infos["Title"] = Tags.get_title(SongLists.current_song)
	Infos["Artist/s"] = Tags.get_artist(SongLists.current_song)
	Infos["Album"] = Tags.get_album(SongLists.current_song)
	Infos["Filetype"] = FormatChecker.get_music_file_extension(SongLists.current_song)
	Infos["Filepath"] = SongLists.current_song
	Infos["Song Duration"] = TimeFormatter.format_seconds( float( Tags.get_song_duration(SongLists.current_song) ) ) + "min"
	
	var x : Tagging = Tagging.new()
	Infos["Sample Rate"] = str( x.GetSongSampleRate(SongLists.current_song) ) + "Hz"
	Infos["Bitrate"] = str( x.GetSongBitrate(SongLists.current_song) ) + "kb/s"
	Infos["Channels"] = str( x.GetSongChannels(SongLists.current_song) )
	
	#Setting Data on Info Spaces
	for i in range(1, InfoSpace.get_child_count()):
		InfoSpace.get_child(i).InitInfoSpace(
			Infos.keys()[i - 1],
			Infos.values()[i - 1]
		)
