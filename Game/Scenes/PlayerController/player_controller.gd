extends Node3D

@export var Player_camera : PlayerCamera3D
@export var Car_to_control : Car


# Called when the node enters the scene tree for the first time.
func _ready():
	$UI/Engine_Power.max_value = Car_to_control.engine_max_power


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$UI/Speed.text = str(Car_to_control.linear_velocity.length() * 1.62137119223733)
	$UI/Engine_Power.value = Car_to_control.engine_force
	if Car_to_control.linear_velocity.length() > Car_to_control.linear_drift_velocity:
		Player_camera.HighSpeed = true
	elif Car_to_control.linear_velocity.length() < Car_to_control.linear_drift_velocity:
		Player_camera.HighSpeed = false
	Player_camera.global_position = lerp(Player_camera.global_position, $chase_near.global_position, .1) 
	Player_camera.look_at($forward.global_position)
	get_input_to_parent()


func get_input_to_parent():
	Car_to_control.steering_force = Input.get_action_strength("Steer_Left") + -Input.get_action_strength("Steer_Right")
	Car_to_control.engine_power = Input.get_action_strength("Throttle")
	Car_to_control.brake_force = Input.get_action_strength("Brake")
