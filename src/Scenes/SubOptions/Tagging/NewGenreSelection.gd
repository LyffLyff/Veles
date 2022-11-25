extends OptionButton

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

func _ready():
	for i in music_genres.size():
		self.add_item(music_genres[i], i)


func _on_GenreSelection2_item_selected(index):
	print(index)
