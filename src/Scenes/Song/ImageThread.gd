class_name CoverLoader extends Reference


#defines how many bytes will be loaded an then compared to delete the duplicate covers
#Higher values amount to the possibility of mistakely thinking two Covers are the some to almost 0
#Lower values are faster, but could Display some files with the wrong Cover
#256 -> very few mistakes -> 2 in 200
#512 -> up to now none
var COVER_DUPLICATE_SAMPLE : int = 256 * 3


func NewSongCovers(var ToCopy : PoolStringArray) -> void:
	if ToCopy.size() > 0:
		var NewSongCovers : Dictionary = CopySongCovers(ToCopy)
		FilteringDuplicateCovers(NewSongCovers)


func CopySongCovers(var ToCopy : PoolStringArray) -> Dictionary:
	
	var DstFolder : String = Global.GetCurrentUserDataFolder() + "/Songs/AllSongs/Covers/"
	var DstCoverPaths : PoolStringArray = []
	var CoverHashes : PoolStringArray = []

	#Creating Destination Paths
	for n in ToCopy.size():
		CoverHashes.push_back( str(ToCopy[n].hash()) ) 
		DstCoverPaths.push_back(DstFolder + CoverHashes[n] + ".png")

	#Copying and getting Successes
	var CopySuccesses : PoolByteArray = Tags.copy_embedded_covers(ToCopy,DstCoverPaths)
	
	#Filtering Copied Covers -> Successful/Unsuccessful
	var CopiedCovers : PoolStringArray = []
	var SucessfulHashes : PoolStringArray = []
	for n in ToCopy.size():
		if CopySuccesses[n]:
			CopiedCovers.push_back(ToCopy[n])
			SucessfulHashes.push_back(CoverHashes[n])
	
	#Returning paths of successfully copied Song Covers
	var x : Dictionary = {}
	
	for n in CopiedCovers.size():
		x[ SucessfulHashes[n] ] = CopiedCovers[n]
	return x;


func FilteringDuplicateCovers(var NewSongs : Dictionary) -> void:
	#This functions compares the Newsongs with the previously added Songs.
	#If it finds a duplicate the Duplucate will be deleted and the Coverhash gets updated
	#NewSongs = {hash : path}
	var X_ImgHeader : PoolByteArray = []
	var Covers : Dictionary = {}
	var YToSkip : Array = []
	
	#Comparing with the New Covers
	for x in NewSongs.size():
		X_ImgHeader = SaveData.load_buffer(Global.GetCurrentUserDataFolder() + "/Songs/AllSongs/Covers/" + NewSongs.keys()[x] + ".png",1024)
		for y in NewSongs.size():
			if !YToSkip.has(x):
				if x != y:
					if X_ImgHeader ==  SaveData.load_buffer(Global.GetCurrentUserDataFolder() + "/Songs/AllSongs/Covers/" + NewSongs.keys()[y] + ".png",1024):
						
						if Covers.has(NewSongs.keys()[x]):
							var Val : PoolStringArray = Covers.get(NewSongs.keys()[x])
							Val.push_back(NewSongs.keys()[y])
							if Covers.erase(NewSongs.keys()[x]):
								Covers[ NewSongs.keys()[x] ] = Val
						else:
							Covers[ NewSongs.keys()[x] ] = [ NewSongs.keys()[y] ]
						
						#Skips the Cover idx since its already marked as a duplicate 
						YToSkip.push_back(y)
				if y >= NewSongs.size() - 1 and !Covers.has(NewSongs.keys()[x]):
					#Adds the Key of the totally unique cover with an empty array as value
					Covers[ NewSongs.keys()[x] ] = []
	
	#Comparing with other Covers
	for x in Covers.size():
		X_ImgHeader = SaveData.load_buffer(Global.GetCurrentUserDataFolder() + "/Songs/AllSongs/Covers/" + Covers.keys()[x] + ".png",1024)
		for y in SongLists.CoverCache.size():
			if X_ImgHeader == SaveData.load_buffer(Global.GetCurrentUserDataFolder() + "/Songs/AllSongs/Covers/" + SongLists.CoverCache.keys()[y] + ".png",1024):
				if !Covers.has(SongLists.CoverCache.keys()[y]):
					var temp : PoolStringArray =  Covers.values()[x]
					temp.push_back( Covers.keys()[x] ) 
					Covers[  SongLists.CoverCache.keys()[y] ] = temp
					if !Covers.erase(Covers.keys()[x]):
						Global.root.message("COULD NOT ERASE HASH FROM COVER DICTIONARY: " + Covers.keys()[x], SaveData.MESSAGE_ERROR)


	for x in Covers.size():
		var UniqueHash : String = Covers.keys()[x]
		if !SongLists.CoverCache.has(UniqueHash):
			SongLists.CoverCache[UniqueHash] = ImageLoader.get_cover(Global.GetCurrentUserDataFolder() + "/Songs/AllSongs/Covers/" + UniqueHash + ".png","",Vector2(70,70))
		for y in Covers.values()[x].size():
			var Temp = null
			var DuplicateHash : String = Covers.values()[x][y]
			Temp = NewSongs.get( DuplicateHash )
			if Temp:
				var path : String = Temp
				AllSongs.set_coverhash(path,UniqueHash)
			else:
				if !SongLists.CoverCache.erase(DuplicateHash):
					Global.root.message("COULD NOT DELETE COVER THAT WAS PREVIOUSLY IN THE COVERCACHE: " + DuplicateHash, SaveData.MESSAGE_ERROR)
			ExtendedDirectory.delete_file(Global.GetCurrentUserDataFolder() + "/Songs/AllSongs/Covers/" + DuplicateHash + ".png")


