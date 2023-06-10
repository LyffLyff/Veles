extends VBoxContainer

var file_path : String = ""
var is_expanded : bool = false

onready var description_edit : TextEdit = $ScrollContainer/Description
onready var scroller : ScrollContainer = $ScrollContainer
onready var expand_button : Button = $Expand

func load_description(var path : String) -> void:
	file_path = path
	var description_text = SaveData.load_data(file_path)
	if description_text != null:
		description_edit.set_text(description_text)


func save_description():
	# automatically creates the given description file if used
	SaveData.save(file_path, description_edit.get_text())


func _on_Expand_pressed():
	var tw : SceneTreeTween = get_tree().create_tween()
	tw = tw.set_trans(Tween.TRANS_BOUNCE)
	if !is_expanded:
		scroller.visible = true
		scroller.modulate.a = 0.0
		var _ptw : PropertyTweener = tw.tween_property(scroller, "rect_min_size:y", 150.0, 0.3)
		_ptw = tw.parallel().tween_property(scroller, "modulate:a", 1.0, 0.3)
		expand_button.icon = load("res://src/assets/Icons/White/General/remove_1_72px.png")
	else:
		var _err : int = tw.connect("finished", scroller, "set_visible", [false])
		var _ptw : PropertyTweener = tw.tween_property(scroller, "rect_min_size:y", 0.0, 0.3)
		_ptw = tw.parallel().tween_property(scroller, "modulate:a", 0.0, 0.3)
		expand_button.icon = load("res://src/assets/Icons/White/General/add_1_72px.png")
	is_expanded = !is_expanded
