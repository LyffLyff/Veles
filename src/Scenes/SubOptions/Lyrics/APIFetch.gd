extends Control

enum {
	SUCCESS = 200,
	MISSING_QUERY_PARAMETER = 400,
	NOT_FOUND = 404,
	NO_RESPONSE
}

signal overwrite_project

const STATIC_URL : String = "https://api.textyl.co/api/lyrics?q="
const VERSE_CONTAINER = preload("res://src/Scenes/SubOptions/Lyrics/VerseContainer.tscn")

onready var scroll : ScrollContainer = $Lyrics/HBoxContainer/ScrollContainer
onready var lyrics_vbox : VBoxContainer = $Lyrics/HBoxContainer/ScrollContainer/VBoxContainer
onready var artist_edit : LineEdit = $Options/HBoxContainer/Keywords/Artist/LineEdit
onready var album_edit : LineEdit = $Options/HBoxContainer/Keywords/Album/LineEdit
onready var title_edit : LineEdit = $Options/HBoxContainer/Keywords/SongTitle/LineEdit

var current_lyrics : Array = []

func _ready():
	# Init
	scroll.get_v_scrollbar().rect_min_size.x = 5
	# API
	var req = HTTPRequest.new()
	self.add_child(req)
	var _err = req.connect("request_completed",self,"api_response")


func api_response(var _result : int, var response_code : int, var _headers : PoolStringArray, var body : PoolByteArray) -> void:
	# Responses:
	# 200 -> Success
	# 400 -> Missing Query Parameters
	# 404 -> Not found
	for verse_idx in lyrics_vbox.get_child_count():
		lyrics_vbox.get_child(verse_idx).queue_free()
	
	match response_code:
		SUCCESS:
			var parse_res : JSONParseResult = JSON.parse(body.get_string_from_utf8())
			current_lyrics = parse_res.result
			lyrics_vbox.set_alignment(BoxContainer.ALIGN_BEGIN)
			for n in current_lyrics.size():
				var x : HBoxContainer = VERSE_CONTAINER.instance()
				lyrics_vbox.add_child(x)
				x.get_child(0).set_text(current_lyrics[n]["lyrics"])
				x.get_child(1).set_text(str(current_lyrics[n]["seconds"]))
		MISSING_QUERY_PARAMETER:
			var x : HBoxContainer = VERSE_CONTAINER.instance()
			x.get_child(0).text = "MISSING_QUERY_PARAMETER -> 400"
			lyrics_vbox.add_child(x)
		NOT_FOUND:
			var x : HBoxContainer = VERSE_CONTAINER.instance()
			x.get_child(0).text = "NOT_FOUND -> 404"
			lyrics_vbox.set_alignment(BoxContainer.ALIGN_CENTER)
			lyrics_vbox.add_child(x)
		NO_RESPONSE:
			var x : HBoxContainer = VERSE_CONTAINER.instance()
			x.get_child(0).text = "Check Internet Connection: NO_RESPONSE -> 0"
			lyrics_vbox.add_child(x)


func create_dynamic_url() -> String:
	var SongInfo : PoolStringArray = [artist_edit.get_text(), album_edit.get_text(), title_edit.get_text()]
	var DynURL : String = ""
	
	for i in SongInfo.size():
		if SongInfo[i] == "":
			continue;
		
		DynURL += SongInfo[i].replace(" ","%20")
		
		if i + 1 < SongInfo.size():
			DynURL += "%20"
	
	return DynURL;


func _on_Fetch_pressed():
	var req = HTTPRequest.new()
	self.add_child(req)
	req.request(STATIC_URL + create_dynamic_url())
	req.connect("request_completed", self, "api_response")


func _on_OverwriteProject_pressed():
	emit_signal("overwrite_project", current_lyrics)
	self.queue_free()
