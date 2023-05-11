extends Control


func _enter_tree():
	Global.active_popups += 1
	Global.root.toggle_songlist_input(false)


func _exit_tree():
	Global.active_popups -= 1
	Global.root.toggle_songlist_input(true)
