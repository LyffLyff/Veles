extends Control

const music_genres : Array = [
	"Pop",
	"Rock",
	"Hip-Hop & Rap",
	"Country",
	"R&B",
	"Folk",
	"Jazz",
	"Heavy Metal",
	"EDM",
	"Soul",
	"Funk",
	"Reggae",
	"Disco",
	"Punk Rock",
	"Classical",
	"House",
	"Techno",
	"Indie Rock",
	"Grunge",
	"Ambient",
	"Gospel",
	"Latin Music",
	"Grime",
	"Trap",
	"Psychedelic Rock"
]

onready var genre_edit : LineEdit = $LineEdit
onready var genre_presets : OptionButton = $GenreSelection

func _ready():
	for i in music_genres.size():
		genre_presets.add_item(music_genres[i], i)


func _on_GenreSelection_item_selected(index):
	genre_edit.set_text(music_genres[index])
