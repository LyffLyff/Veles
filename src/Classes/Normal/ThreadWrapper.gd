extends Node
class_name ThreadWrapper

var terminated : bool = false
var thread : Thread = Thread.new()

func is_terminated() -> bool:
	return terminated

func stop() -> void:
	self.terminated = true


func start_thread(var object : Object, var method : String, var userdata, var priority : int = Thread.PRIORITY_NORMAL) -> int:
	return thread.start(object, method, userdata, priority)


func end_thread() -> void:
	if thread.is_active():
		thread.wait_to_finish()
	self.queue_free()


func _exit_tree():
	if is_instance_valid(thread):
		if !thread.is_active():
			return
		self.terminated = true
		thread.wait_to_finish()
