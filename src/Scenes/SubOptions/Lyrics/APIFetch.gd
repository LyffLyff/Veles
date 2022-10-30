extends Control

#ENUMS
enum {
	SUCCESS = 200,
	MISSING_QUERY_PARAMETER = 400,
	NOT_FOUND = 404,
	NO_RESPONSE
}

#SIGNALS
signal OverwriteProject

#CONSTANTS
const StaticURL : String = "https://api.textyl.co/api/lyrics?q="

#NODES
onready var Scroll : ScrollContainer = $Lyrics/HBoxContainer/ScrollContainer
onready var Lyrics : VBoxContainer = $Lyrics/HBoxContainer/ScrollContainer/VBoxContainer
onready var ArtistEdit : LineEdit = $Options/HBoxContainer/Keywords/Artist/LineEdit
onready var AlbumEdit : LineEdit = $Options/HBoxContainer/Keywords/Album/LineEdit
onready var TitleEdit : LineEdit = $Options/HBoxContainer/Keywords/SongTitle/LineEdit

#PRELOADS
const VerseContainer = preload("res://src/Scenes/SubOptions/Lyrics/VerseContainer.tscn")

#Variables
var CurrentLyrics : Array = []


func _ready():
	#Init
	Scroll.get_v_scrollbar().rect_min_size.x = 5
	
	#API
	var req = HTTPRequest.new()
	self.add_child(req)
	var _err = req.connect("request_completed",self,"APIResponse")


func APIResponse(var _result : int, var response_code : int, var _headers : PoolStringArray, var body : PoolByteArray) -> void:
	#Responses:
	#200 -> Success
	#400 -> Missing Query Parameters
	#404 -> Not found
	for VerseIdx in Lyrics.get_child_count():
		Lyrics.get_child(VerseIdx).queue_free()
	
	print("RES: ",response_code)
	match response_code:
		SUCCESS:
			var parse_res : JSONParseResult = JSON.parse(body.get_string_from_utf8())
			CurrentLyrics = parse_res.result
			Lyrics.set_alignment(BoxContainer.ALIGN_BEGIN)
			for n in CurrentLyrics.size():
				var x : HBoxContainer = VerseContainer.instance()
				Lyrics.add_child(x)
				x.get_child(0).set_text(CurrentLyrics[n]["lyrics"])
				x.get_child(1).set_text( str(CurrentLyrics[n]["seconds"]) )
		MISSING_QUERY_PARAMETER:
			var x : HBoxContainer = VerseContainer.instance()
			x.get_child(0).text = "MISSING_QUERY_PARAMETER -> 400"
			Lyrics.add_child(x)
		NOT_FOUND:
			var x : HBoxContainer = VerseContainer.instance()
			x.get_child(0).text = "NOT_FOUND -> 404"
			Lyrics.set_alignment(BoxContainer.ALIGN_CENTER)
			Lyrics.add_child(x)
		NO_RESPONSE:
			var x : HBoxContainer = VerseContainer.instance()
			x.get_child(0).text = "Check Internet Connection: NO_RESPONSE -> 0"
			Lyrics.add_child(x)


func OnFetchLyrics():
	var req = HTTPRequest.new()
	self.add_child(req)
	req.request(StaticURL + CreateDynamicURL())
	req.connect("request_completed",self,"APIResponse")


func CreateDynamicURL() -> String:
	var SongInfo : PoolStringArray = [ArtistEdit.get_text(), AlbumEdit.get_text(), TitleEdit.get_text()]
	var DynURL : String = ""
	
	for i in SongInfo.size():
		if SongInfo[i] == "":
			continue;
		
		DynURL += SongInfo[i].replace(" ","%20")
		
		if i + 1 < SongInfo.size():
			DynURL += "%20"
	
	return DynURL;


func OnOverwriteProject():
	emit_signal("OverwriteProject", CurrentLyrics)
	self.queue_free()
