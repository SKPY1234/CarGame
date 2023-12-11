extends VehicleBody3D

class_name Car

@export var engine_max_power = 100.0
@export var engine_tourque = 100.0
@export var engine_acceleration = .7
@export var linear_drift_velocity = 15.0

@export var brake_multiplier = 200.0

@export var steering_width = .80

@export var Player_Camera : PlayerCamera3D

var brake_force = 0.0
var engine_power = 0.0
var engine_direction = 1.0
var steering_force = 0.0
var Reversing = false
var current_tourque
# brake engine_force emass steering


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if linear_velocity.length() > 1.0 and !Reversing:
		$AtRest.start()
	
	var inirtia = linear_velocity * .25
	
	apply_central_force(inirtia * delta)
	
	if $AtRest.is_stopped():
		Reversing = true
	if engine_power > 0.0:
		Reversing = false
		engine_direction = 1.0
	if brake_force != 0.0:
		if Reversing:
			engine_direction = -1.0
			engine_power = .5
		else:
			$FL.brake = brake_force * brake_multiplier
			$FR.brake = brake_force * brake_multiplier
	elif brake_force == 0.0:
		$FL.brake = 0.0
		$FR.brake = 0.0
	## Apply drag
	#apply_force(-linear_velocity * .1)
	
	
	engine_tourque = lerp(engine_tourque, engine_power * engine_max_power, .01)
	
	engine_force = lerpf(engine_force, (engine_power * engine_direction) * engine_tourque, engine_acceleration)
	clamp(engine_force, -20.0, engine_max_power)
	steering = lerpf(steering, steering_force * steering_width, .050)
	

