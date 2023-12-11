extends Node3D




signal FOLLOWNODEPOS(node_position)

@onready var car = get_node("..")
@onready var body = $"../CollisionShape3D/body"
var AICARPOS
var AINODEFOLLOW

@onready var CarModles = ["res://Game/Scenes/Car/Cars/FormulaOne2.tres", "res://Game/Scenes/Car/Cars/FormulaOne.tres", "res://Game/Scenes/Car/Cars/HatchBackSpors.tres", "res://Game/Scenes/Car/Cars/Hummer.tres", "res://Game/Scenes/Car/Cars/Jeep.tres", "res://Game/Scenes/Car/Cars/Sedan.tres", "res://Game/Scenes/Car/Cars/TallBed.tres", "res://Game/Scenes/Car/Cars/Taxi.tres", "res://Game/Scenes/Car/Cars/Truck.tres", "res://Game/Scenes/Car/Cars/Van.tres"]

@onready var navigation_agent_3d : NavigationAgent3D = get_node("../NavigationAgent3D")


var raycasts = []
var danger = []
var intrest = []
var num_rays = 3 * 9

var chosen_dir


func _ready():
	var selectedCarModle = randi() % CarModles.size() - 1
	body.mesh = load( CarModles[selectedCarModle] )
	
	for i in num_rays:
		var raycast = RayCast3D.new()
		var angle = (i * (2 * PI / num_rays)) - PI  # This will range from -PI to PI
		raycast.position = Vector3(0, 1, 0)
		raycast.rotation = Vector3(0, angle, 0)
		
		# Make the rays shorter on the outside of the fan
		var ray_out = -15 * cos(angle)  # cos(angle) ranges from -1 to 1
		
		raycast.target_position = Vector3(0, 0, ray_out)
		raycast.set_collision_mask_value(2, true)
		raycast.enabled = true
		
		car.call_deferred("add_child", raycast)
		raycasts.append(raycast)
		
		
	var AICARPOSINST = PathFollow3D.new()
	var AINODEFOLLOWINST = Node3D.new()
	
	
	await get_node("../../..").ready
	
	
	get_node("../../..").add_child(AICARPOSINST)
	
	get_node(str("../../../" , AICARPOSINST.name)).add_child(AINODEFOLLOWINST)
	
	
	
	print(str("../../../" , AICARPOSINST.name))
	
	AICARPOS = get_path_to(AICARPOSINST)
	
	
	AINODEFOLLOW = get_path_to(AINODEFOLLOWINST)


func _physics_process(delta):
	if !$"../Uncollidable".is_stopped():
		car.set_collision_mask_value(2,false)
	
	if $"../Uncollidable".is_stopped():
		car.set_collision_mask_value(2,true)
	
	
	var target_node : PathFollow3D = get_node(AICARPOS)
	var ai_node_follow : Node3D = get_node(AINODEFOLLOW)
	
	emit_signal("FOLLOWNODEPOS", global_transform.origin)
	
	if car.linear_velocity.length() > 1.0:
		$"../Reset_Car".stop()
	
	if $"../Reset_Car".is_stopped():
		if car.linear_velocity.length() < 1.0:
			$"../Reset_Car".start($"../Reset_Car".wait_time)
		
	
	if target_node != null:
		
		$"../Tracker".global_position = target_node.global_position
		
		car.brake_force = 0.0
		
		if navigation_agent_3d.is_target_reachable():
			
			#print("Progress = ",target_node.progress)
			
			
			navigation_agent_3d.target_position = ai_node_follow.global_position
			
			var transform1 : Transform3D = car.global_transform
			var transform2 : Transform3D  = target_node.global_transform
			
			var forwardVec1 : Vector3 = -transform1.basis.z
			var forwardVec2 : Vector3 = -transform2.basis.z
			
			var angleInRadians : float = forwardVec1.angle_to(forwardVec2)
			
			var angleInDegrees = angleInRadians * (180 / PI)
			
			var crossProduct = forwardVec1.cross(forwardVec2)
			
			
			if angleInDegrees > 10:
				car.brake_force += 0.001
			
			if crossProduct.y < 0:
				angleInDegrees = -angleInDegrees
			
			var steering_adjustment = 0.0
			for raycast in raycasts:
				if raycast.is_colliding():
					if car.global_transform.origin.distance_to( raycast.get_collision_point() ) < 5.0:
						car.brake_force += 0.001
					var raycast_dir = raycast.global_transform.basis.z
					var angle = forwardVec1.angle_to(raycast_dir) * (180 / PI)
					var altered_crossProduct = forwardVec1.cross(raycast_dir)
					if altered_crossProduct.y < 0:
						angle = -angle
					steering_adjustment += angle / raycast.get_collision_point().distance_to(car.global_transform.origin)
			
			#print("Distance = ", navigation_agent_3d.distance_to_target())
			
			#print("Angle = ", (angleInDegrees / 180))
			
			car.steering_force = ((angleInDegrees + steering_adjustment) / 180)
			
			car.engine_power = 1.0
			
			
			
			
			if navigation_agent_3d.distance_to_target() < 20:
				target_node.progress = target_node.progress + 1
			
			
			if navigation_agent_3d.distance_to_target() > 300:
				_on_reset_car_timeout()
	#set_danger()
	#choose_direction()


func _process(delta):
	$"../LapCount".text = str( navigation_agent_3d.distance_to_target() )








func _on_reset_car_timeout():
	car.global_position = get_node(AINODEFOLLOW).global_position + Vector3(0, 2, 0)
	car.global_transform = get_node(AINODEFOLLOW).global_transform
	$"../Uncollidable".start()
