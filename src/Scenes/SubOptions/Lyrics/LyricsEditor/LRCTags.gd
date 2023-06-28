extends VBoxContainer

const EXPAND_DURATION : float = 0.2

var min_height : float
var is_expanded : bool = false
var is_tweening : bool = false

onready var artist_edit : LineEdit = $VBoxContainer/Artist/LineEdit
onready var album_edit : LineEdit = $VBoxContainer/Album/LineEdit
onready var title : LineEdit = $VBoxContainer/Title/LineEdit
onready var author_edit : LineEdit = $VBoxContainer/Author/LineEdit
onready var song_length_edit : LineEdit = $VBoxContainer/SongLength/LineEdit
onready var language_menu : OptionButton = $VBoxContainer/ISO6391LanguageSelection/ISO6391LanguageSelection
onready var file_creator_edit : LineEdit = $VBoxContainer/CreatorOfFile/LineEdit
onready var tag_vbox : VBoxContainer = $VBoxContainer
onready var pointer : TextureRect = $LRCTags/HBoxContainer/Pointer

func _ready():
	min_height = self.rect_min_size.y


func _on_LRCTags_pressed():
	if is_tweening:
		#prevents another tween from running if it's currently running
		return;
		
	var tw : SceneTreeTween = create_tween()
	tw = tw.set_trans(Tween.TRANS_QUAD)
	
	is_tweening = true
	if !is_expanded:
		var ptw : PropertyTweener = tw.tween_property(self, "rect_min_size:y", min_height * tag_vbox.get_child_count(), EXPAND_DURATION)
		ptw = tw.parallel().tween_property(pointer,"rect_rotation", 180.0, EXPAND_DURATION)
		yield(tw,"finished")
		tag_vbox.visible = true
	else:
		var ptw : PropertyTweener = tw.tween_property(self, "rect_min_size:y", min_height, EXPAND_DURATION)
		ptw = tw.parallel().tween_property(pointer,"rect_rotation", 0.0, EXPAND_DURATION)
		tag_vbox.visible = false
		yield(tw,"finished")

	is_tweening = false
	is_expanded = !is_expanded
