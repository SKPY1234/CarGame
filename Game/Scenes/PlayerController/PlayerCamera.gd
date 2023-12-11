extends Camera3D

class_name PlayerCamera3D

var HighSpeed = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	speed_lines()


func speed_lines():
	if HighSpeed:
		$GPUParticles3D.show()
	else:
		$GPUParticles3D.hide()
