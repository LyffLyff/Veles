extends Reference


class_name SmartPlaylistConditions


func IsLongerThan(var SongPath : String, var LengthInSeconds : String) -> bool:
	#Returns true if the given Song is Longer than the Given Duration
	return AllSongs.GetSongDuration( AllSongs.GetMainIdx( SongPath ) ) >= int( LengthInSeconds );


func IsShorterThan(var SongPath : String, var LengthInSeconds : String) -> bool:
	#Returns true if the given Song is Shorter than the Given Duration
	return AllSongs.GetSongDuration( AllSongs.GetMainIdx( SongPath ) ) <= int( LengthInSeconds );


func Genre(var SongPath : String, var GenreType : String) -> bool:
	#Returns true if the given Genre is equal to the Genre specified in the Songs Tag
	return Tags.GetGenre( SongPath ) == GenreType;


#Album
func Album(var SongPath : String, var AlbumTitle : String) -> bool:
	#Returns true if the given Album Title is equal to the Album Title specified in the Songs Tag
	return Tags.GetAlbum( SongPath ) == AlbumTitle;


#Artist
func IncludesArtist(var SongPath : String, var ArtistName : String) -> bool:
	return ArtistName in AllSongs.GetSongArtist( AllSongs.GetMainIdx(SongPath) );


func DoesNotIncludeArtist(var SongPath : String, var ArtistName : String) -> bool:
	#Returns true if the Artist not in the String
	return !( ArtistName in AllSongs.GetSongArtist( AllSongs.GetMainIdx(SongPath) ) );


func IncludesEitherArtist(var SongPath : String, var Artists : PoolStringArray) -> bool:
	#Returns true if any of the given Artists is cited as Artist in the given Song
	var SongArtists : String = AllSongs.GetSongArtist( AllSongs.GetMainIdx(SongPath) )
	for Artist in Artists:
		if Artist in SongArtists:
			return true;
	return false;


#Lyrics
func HasEmbeddedLyrics(var _SongPath : String) -> bool:
	#returns true if the given Song has either UNSYNCHED/SYNCHED Lyrics
	return false;

func HasSynchedLyrics(var _SongPath : String) -> bool :
	return false;

func HasUnsynchedLyrics(var _SongPath : String) -> bool :
	return false;


#Title
func TitleIncludes(var SongPath : String, var SearchString : String) -> bool:
	var TagTitle : String = Tags.new().GetTitle(SongPath)
	return TagTitle.find( SearchString ) != -1 


#Song Rating
func SongRatingIs(var SongPath : String, var RatingOutOf10 : String) -> bool:
	#Return if the Song Rating out of 10 given is the same as the Songs Rating
	var EmbeddedRating = Tagging.new().GetSongPopularity(SongPath)[0]
	if typeof(EmbeddedRating) != TYPE_INT:
		return false
	return EmbeddedRating == int(RatingOutOf10)

func SongRatingIsHigher(var SongPath : String, var RatingOutOf10 : String) -> bool:
	var EmbeddedRating = Tagging.new().GetSongPopularity(SongPath)[0]
	if typeof(EmbeddedRating) != TYPE_INT:
		return false
	return EmbeddedRating > int(RatingOutOf10)

func SongRatingIsLower(var SongPath : String, var RatingOutOf10 : String) -> bool:
	var EmbeddedRating = Tagging.new().GetSongPopularity(SongPath)[0]
	if typeof(EmbeddedRating) != TYPE_INT:
		return false
	return EmbeddedRating < int(RatingOutOf10)


#Cover
func HasCover(var _SongPath : String) -> bool:
	return false

func HasTheSameCoverAs(var _SongPath : String, var _CoverSrc : String) -> bool:
	return false
