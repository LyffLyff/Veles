# a scene that creates a list of all the conditions of a given smart playlist
# these conditions can be edited and saved at the end
extends ScrollContainer

const condition_functions : Dictionary = {
	# the names this function can be called : needed type of argument
	"genre" : TYPE_STRING,
	"album" : TYPE_STRING,
	"is_longer_than" : TYPE_STRING,
	"is_shorter_than" : TYPE_STRING,
	"includes_either_artist" : TYPE_STRING_ARRAY,
	"song_rating_is" : TYPE_STRING,
	"song_rating_is_greater" : TYPE_STRING,
	"song_rating_is_lesser" : TYPE_STRING,
}

onready var condition_vbox : VBoxContainer = $HBoxContainer/VBoxContainer

var conditions_folder : String = Global.get_current_user_data_folder() + "/Songs/Playlists/SmartPlaylists/Conditions/"
var condition_file : String = ""


func init_conditions(var smart_playlist_title : String) -> void:
	condition_file = smart_playlist_title + ".dat"
	load_conditions()


func load_conditions() -> void:
	# load conditions from file
	var conditions : Dictionary = {}
	var temp = SaveData.load_data(conditions_folder + condition_file)
	if temp is Dictionary:
		conditions = temp
	
	# set conditions in LineEdits
	var condition_value : Array
	var temp_line_edit : LineEdit = null
	for i in condition_vbox.get_child_count():
		
		# get condition value
		match condition_functions.values()[i]:
			TYPE_STRING:
				condition_value = conditions.get(condition_functions.keys()[i], [])
			TYPE_STRING_ARRAY:
				condition_value = conditions.get(condition_functions.keys()[i], [])[0]
		
		# create LineEdits and fill with content
		for j in condition_value.size():
			if j == 0:
				temp_line_edit = condition_vbox.get_child(i).path_edit_vbox.get_child(0).get_child(1)
			else:
				condition_vbox.get_child(i).add_selection()
				temp_line_edit = condition_vbox.get_child(i).path_edit_vbox.get_child(j).get_child(1)
			temp_line_edit.text = condition_value[j]


func save_conditions(var conditions_filename : String = condition_file) -> void:
	# retrieving conditions from LineEdits
	var conditions : Dictionary = {}
	var condition_values : Array = []
	var temp_condition_value : String = ""
	for i in condition_vbox.get_child_count():
		
		# retrieve the conditions values
		condition_values = PoolStringArray()
		for y in condition_vbox.get_child(i).path_edit_vbox.get_child_count():
			temp_condition_value = condition_vbox.get_child(i).path_edit_vbox.get_child(y).get_child(1).text
			if temp_condition_value != "":
				condition_values.push_back(temp_condition_value)
		
		# format the conditions by their needed variant type
		match condition_functions.values()[i]:
			TYPE_STRING:
				conditions[condition_functions.keys()[i]] = condition_values
			TYPE_STRING_ARRAY:
				conditions[condition_functions.keys()[i]] = [condition_values]
	
	# saving conditions to file
	SaveData.save(conditions_folder + conditions_filename, conditions)
