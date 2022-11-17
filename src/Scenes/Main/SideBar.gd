extends ScrollContainer

const ICON_TOGGLE_WIDTH : int = 1000
const CONTRACTED_SIZE : float = 40.0
const EXPANDED_SIZE : float = 120.0

var icons_visible : bool = false

onready var sub_options : VBoxContainer = $HBoxContainer/VBoxContainer/Options
onready var user_profile_container : PanelContainer = $HBoxContainer/VBoxContainer/UserProfileBox


func _ready():
	# init
	self.rect_min_size.x = EXPANDED_SIZE
	update_sidebar(0.0)
	
	# initialising color
	self.get_stylebox("bg").set(
		"bg_color",
		SettingsData.get_setting(SettingsData.DESIGN_SETTINGS,"MainOptionsBackground")
	)
	
	# hiding Scrollbar
	self.get_v_scrollbar().modulate = "00000000"


func update_sidebar(var duration : float = 0.3) -> void:
	match SettingsData.get_setting(SettingsData.DESIGN_SETTINGS, "SidebarMode"):
		0:
			#Automatic
			if Global.root.get_rect().size.x < ICON_TOGGLE_WIDTH:
				contract_sidebar(duration)
			else:
				if icons_visible:
					expand_sidebar(duration)
				else:
					return;
		1:
			#Expanded
			if icons_visible:
				expand_sidebar(duration)
		2:
			#Contracted
			if !icons_visible:
				contract_sidebar(duration)
	sub_options.toggle_icons(icons_visible)


func contract_sidebar(var duration : float) -> void:
	var tw : SceneTreeTween = get_tree().create_tween()
	icons_visible = true
	user_profile_container.username_label.hide()
	var ptw : PropertyTweener = tw.tween_property(
		self,
		"rect_min_size:x",
		CONTRACTED_SIZE,
		duration
	)


func expand_sidebar(var duration : float) -> void:
	icons_visible = false
	var tw : SceneTreeTween = get_tree().create_tween()
	var ptw : PropertyTweener = tw.tween_property(
	self,
	"rect_min_size:x",
	EXPANDED_SIZE,
	duration
	)
	yield(tw,"finished")
	user_profile_container.username_label.show()
