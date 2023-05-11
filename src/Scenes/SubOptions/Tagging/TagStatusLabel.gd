extends Label

enum STATUSES {
	SINGLE_FILE_UNSAVED,
	SINGLE_FILE_SAVED
}

var current_status : int = STATUSES.SINGLE_FILE_SAVED


func _ready():
	set_status(current_status)


func set_status(var new_status : int) -> void:
	current_status = new_status
	match new_status:
		STATUSES.SINGLE_FILE_UNSAVED:
			self.text = "* UNSAVED FILE"
		STATUSES.SINGLE_FILE_SAVED:
			self.text = "FILE SAVED"
