extends Reference

class_name Tags


#Retriving Tag
static func GetMultipleTags(var path : String,var flags : PoolIntArray) -> PoolStringArray:
	var x : Tagging = Tagging.new()
	return x.GetMultipleTags(path,flags)

static func GetArtist(var path : String) -> String:
	var x : Tagging = Tagging.new()
	return x.GetSingleTag(path,0)


static func GetTitle(var path : String) -> String:
	var x : Tagging = Tagging.new()
	return x.GetSingleTag(path,1)


static func GetAlbum(var path : String) -> String:
	var x : Tagging = Tagging.new()
	return x.GetSingleTag(path,2)


static func GetGenre(var path : String) -> String:
	var x : Tagging = Tagging.new()
	return x.GetSingleTag(path,3)


static func GetSongDuration(var path : String) -> int:
	var x : Tagging = Tagging.new()
	return x.GetSongDuration(path)


static func CopyCovers(var src_paths : PoolStringArray, var dst_paths : PoolStringArray) -> PoolByteArray:
	var cpp = Tagging.new()
	return cpp.CopyAllCovers(src_paths,dst_paths)



#Setting Tag
static func SetArtist(var data : String, var path : String) -> void:
	SetTag(0,data,path)


static func SetTitle(var data : String, var path : String) -> void:
	SetTag(1,data,path)


static func SetAlbum(var data : String, var path : String) -> void:
	SetTag(2,data,path)


static func SetGenre(var data : String, var path : String) -> void:
	SetTag(3,data,path)


static func SetComment(var data : String, var path : String) -> void:
	#New Comment using ID3v2 will be located at the end of the file 
	SetTag(4,data,path)


static func SetTrackNumber(var TrackNumber : String, var path : String) -> void:
	SetTag(6,TrackNumber,path)


static func SetReleaseYear(var ReleaseYear : String, var path : String) -> void:
	SetTag(5,ReleaseYear,path)


static func SetCover(var img_path : String, var song_path : String, var MimeType : String) -> void:
	var x : Tagging = Tagging.new()
	x.SetCover(img_path, song_path,MimeType)


static func SetTag(var flag : int, var data : String,var path : String) -> void:
	var x : Tagging = Tagging.new()
	x.SetTag(flag,data,path)


static func GetTagType(var Songpath : String) -> String:
	var x : Tagging = Tagging.new()
	return x.GetTagType(Songpath)

static func ReturnCoverData(var SrcPath : String) -> PoolByteArray:
	var x : Tagging = Tagging.new()
	return x.GetMusicCover(SrcPath)


static func ReturnAllCoverData(var SrcPath : String) -> Array:
	var x : Tagging = Tagging.new()
	return x.GetAllMusicCovers(SrcPath)


#Cover Description
static func GetCoverDescription(var SrcPath : String) -> String:
	return Tagging.new().GetCoverDescription(SrcPath)


static func SetCoverDescription(var SrcPath : String, var NewCoverDescription : String) -> void:
	Tagging.new().SetCoverDescription(SrcPath, NewCoverDescription)


#Lyrics
static func SetLyrics(var SrcPaths : PoolStringArray,var IsSynchronized : bool, var Verses : PoolStringArray, var TimeStampsInSeconds : PoolRealArray) -> void:
	#Timestamps MUST be in absolute milliseconds -> specification of the Frame
	#Timestamps get converted to Milliseconds since Veles works with seconds
	var TimestampInAbsoluteMilliSeconds : PoolIntArray = []
	for i in TimeStampsInSeconds:
		#converting the timestamps from seconds to milliseconds
		TimestampInAbsoluteMilliSeconds.push_back( int(i * 1000.0) )
	
	var x : Tagging = Tagging.new()
	for SrcPath in SrcPaths:
		x.SetLyrics(SrcPath, Verses, TimestampInAbsoluteMilliSeconds,IsSynchronized)


static func GetLyrics(var SongPath : String) -> Array:
	#Synched: [Verses, Timestamps in absolute milliSeconds]
	#Unsyched: [Lyrics as single long String]
	var cpp = Tagging.new()
	return cpp.GetLyrics(SongPath)
