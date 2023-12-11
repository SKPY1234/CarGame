extends Node3D

var target_position = Vector3(0, 0, 0) # Replace with the actual target position


func _process(delta):
	var direction = (target_position - global_transform.origin)
	self.rotation = direction


func _on_ai_follownodepos(node_position):
	target_position.z = node_position.z
	#target_position.y = node_position.y
	target_position.x = node_position.x
	
