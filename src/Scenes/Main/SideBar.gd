extends ScrollContainer

#CONSTANTS
const ICON_TOGGLE_WIDTH : int = 1000
const CONTRACTED_SIZE : float = 40.0
const EXPANDED_SIZE : float = 120.0

#VARIABLE
var IconsShown : bool = false

#NODES
onready var Options : VBoxContainer = $HBoxContainer/VBoxContainer/Options
onready var UserProfile : PanelContainer = $HBoxContainer/VBoxContainer/UserProfileBox


func _ready():
	#Init
	self.rect_min_size.x = EXPANDED_SIZE
	UpdateSidebar(0.0)
	
	#Setting Desgin
	self.get_stylebox("bg").set(
		"bg_color",
		SettingsData.GetSetting(SettingsData.DESIGN_SETTINGS,"MainOptionsBackground")
	)
	
	#Hiding Scrollbar
	self.get_v_scrollbar().modulate = "00000000"


func UpdateSidebar(var Duration : float = 0.3) -> void:
	match SettingsData.GetSetting(SettingsData.DESIGN_SETTINGS, "SidebarMode"):
		0:
			#Automatic
			if Global.root.get_rect().size.x < ICON_TOGGLE_WIDTH:
				ContractSidebar(Duration)
			else:
				if IconsShown:
					ExpandSidebar(Duration)
				else:
					return;
		1:
			#Expanded
			if IconsShown:
				ExpandSidebar(Duration)
		2:
			#Contracted
			if !IconsShown:
				ContractSidebar(Duration)
	Options.ToggleIcons(IconsShown)


func ContractSidebar(var Duration : float) -> void:
	var tw : SceneTreeTween = get_tree().create_tween()
	IconsShown = true
	UserProfile.UsernameLabel.hide()
	var ptw : PropertyTweener = tw.tween_property(
		self,
		"rect_min_size:x",
		CONTRACTED_SIZE,
		Duration
	)


func ExpandSidebar(var Duration : float) -> void:
	IconsShown = false
	var tw : SceneTreeTween = get_tree().create_tween()
	var ptw : PropertyTweener = tw.tween_property(
	self,
	"rect_min_size:x",
	EXPANDED_SIZE,
	Duration
	)
	yield(tw,"finished")
	UserProfile.UsernameLabel.show()
