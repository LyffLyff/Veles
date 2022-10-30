extends Reference


#The .lrc file format is a format used to synchronize lyrics to an audiofile
#It can be used in the formats MP3, OGG Vorbis and MIDI
#This class will hold function to create and read .lrc files and make them into lyric editor projects
#[mm:ss.cc][Minutes:Seconds:Hundreeths]
#the . between ss and cc can also be a : depending on the program used -> Veles uses .
#[ar: Artist/s]
#[al: Album, from where this Song originates from]
#[ti: Title of Song]
#[au: Author and/or Composer]
#[length: Length of Audio File]
#[la: Two Letters representing the Langauge of Lyrics in ISO-639-1 Notation]
#[by:Creator of this LRC-File]
#[re:Veles -> Automatic]
#[ve:Veles Version -> Automatic]

class_name LRC

#CONSTANTS
const InfoTags : Dictionary = {
	"ar:" : "",
	"al:" : "",
	"ti:" : "",
	"au:" : "",
	"length:" : "",
	"la:" : "",
	"by:" : "",
	"re:" : "",
	"ve:" : ""
}



func EncodeLRCFile(
	var Verses : PoolStringArray,
	var TimeStampsInSeconds : PoolRealArray = [],
	var Artist : String = "",
	var Album : String = "",
	var Title : String = "",
	var Author : String = "",
	var SongLength : String = "",
	var Language : String = "",
	var CreatorOfLRCFile : String = ""
	) -> String:
	
	var LRCFile : String = ""
	#Header
	LRCFile += "[re:Veles Music Tool https://lyfflyff.itch.io/veles]\n"
	if Artist.length() > 0:
		LRCFile += "[" + InfoTags.keys()[0] + Artist + "]" + "\n"
	if Album.length() > 0:
		LRCFile += "[" + InfoTags.keys()[1] + Album + "]" + "\n"
	if Title.length() > 0:
		LRCFile += "[" + InfoTags.keys()[2] + Title + "]" + "\n"
	if Author.length() > 0:
		LRCFile += "[" + InfoTags.keys()[3] + Author + "]" + "\n"
	if SongLength != "":
		LRCFile += "[" + InfoTags.keys()[4] + SongLength + "]" + "\n"
	if Language != "":
		#the given Language will ALWAYS be in the right format
		LRCFile += "[" + InfoTags.keys()[5] + Language + "]" + "\n"
	if CreatorOfLRCFile != "":
		LRCFile += "[" + InfoTags.keys()[6] + CreatorOfLRCFile + "]" + "\n"
	
	#Lyrics
	var TempTimeStamp : String = ""
	for i in Verses.size():
		if TimeStampsInSeconds.size() > i:
			TempTimeStamp = TimeFormatter.SecondsToLRCTimestamp(TimeStampsInSeconds[i])
		else:
			TempTimeStamp = "[00:00.00]"
		LRCFile += TempTimeStamp + Verses[i] + "\n"
	
	#Erasing the last Newline from the file, since it's not needed
	LRCFile.erase(LRCFile.length() - 1,2)
	
	return LRCFile


func DecodeLRCFile(var LRCFileData : String) -> Array:
	#This function Returns an Array with all the possible properties of a LRC File
	#If the property does not exist in the LRC file it will be set as the Variant, but empty
	var DecodedLRCFile : Array = [InfoTags]
	
	#Header
	var PriorOpenBracketidx : int = -1
	var OpenBracketIdx : int = -1
	var CloseBracketIdx : int = -1
	var ColonIdx : int = -1
	var TempLRCTag : String = ""
	var TempLRCTagData : String = ""
	var LRCTagIdx : int = -1
	while true:
		PriorOpenBracketidx = OpenBracketIdx
		OpenBracketIdx = LRCFileData.find("[",OpenBracketIdx + 1)
		CloseBracketIdx = LRCFileData.find("]",OpenBracketIdx + 1)
		ColonIdx = LRCFileData.find(":",OpenBracketIdx + 1)
		TempLRCTag = LRCFileData.substr(OpenBracketIdx + 1, ColonIdx - OpenBracketIdx)
		if InfoTags.has(TempLRCTag):
			#Getting the LRC Tag Data if the Tag is valid
			TempLRCTagData = LRCFileData.substr(ColonIdx + 1, CloseBracketIdx - ColonIdx - 1)
			DecodedLRCFile[0][TempLRCTag] = TempLRCTagData
		else:
			break;
	
	#Lyrics
	var Verses : PoolStringArray = []
	var Timestamps : PoolRealArray = []
	
	while true:
		#Retrieving Timestamp
		Timestamps.push_back(
			TimeFormatter.LRCTimeStampToSeconds(
				LRCFileData.substr(OpenBracketIdx, CloseBracketIdx - OpenBracketIdx)
			)
		)
		
		#Retrieving Corresponding Verse
		OpenBracketIdx = LRCFileData.find("[",CloseBracketIdx)
		#Checking for end of LRC File
		if OpenBracketIdx == -1:
			#if this is the Last Verse to Add and not the only one
			Verses.push_back(
				LRCFileData.substr(CloseBracketIdx + 1, LRCFileData.length() - CloseBracketIdx - 1)
			)
			break;
		else:
			#If there is another Verse to Add
			Verses.push_back(
				LRCFileData.substr(CloseBracketIdx + 1, OpenBracketIdx - CloseBracketIdx - 2)
			)
			CloseBracketIdx = LRCFileData.find("]",OpenBracketIdx + 1)
	
	DecodedLRCFile.push_back(Verses)
	DecodedLRCFile.push_back(Timestamps)
	
	#Returning the Decoded LRC Files as Array
	#[{LRC_TAGS}, Verses, Timestamps]
	return DecodedLRCFile;
