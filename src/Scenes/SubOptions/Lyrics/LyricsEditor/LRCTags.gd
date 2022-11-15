extends VBoxContainer


#CONSTANTS
const EXPAND_DURATION : float = 0.2


#NODES 
onready var Artist : LineEdit = $VBoxContainer/Artist/LineEdit
onready var Album : LineEdit = $VBoxContainer/Album/LineEdit
onready var Title : LineEdit = $VBoxContainer/Title/LineEdit
onready var Author : LineEdit = $VBoxContainer/Author/LineEdit
onready var SongLength : LineEdit = $VBoxContainer/SongLength/LineEdit
onready var Language : MenuButton = $VBoxContainer/ISO6391LanguageSelection/ISO6391LanguageSelection
onready var CreatorOfFile : LineEdit = $VBoxContainer/CreatorOfFile/LineEdit
onready var TagVBox : VBoxContainer = $VBoxContainer
onready var pointer : TextureRect = $LRCTags/HBoxContainer/Pointer


#VARIABLES
var MinY : float
var IsExpanded : bool = false
var IsTweening : bool = false


func _ready():
	MinY = self.rect_min_size.y


func OnLRCTagsPressed():
	if IsTweening:
		#prevents another tween from running if it's currently running
		return;
		
	var tw : SceneTreeTween = create_tween()
	tw = tw.set_trans(Tween.TRANS_QUAD)
	
	IsTweening = true
	if !IsExpanded:
		var ptw : PropertyTweener = tw.tween_property(self, "rect_min_size:y", MinY * TagVBox.get_child_count(), EXPAND_DURATION)
		ptw = tw.parallel().tween_property(pointer,"rect_rotation", 180.0, EXPAND_DURATION)
		yield(tw,"finished")
		TagVBox.visible = true
	else:
		var ptw : PropertyTweener = tw.tween_property(self, "rect_min_size:y", MinY, EXPAND_DURATION)
		ptw = tw.parallel().tween_property(pointer,"rect_rotation", 0.0, EXPAND_DURATION)
		TagVBox.visible = false
		yield(tw,"finished")

	IsTweening = false
	IsExpanded = !IsExpanded
