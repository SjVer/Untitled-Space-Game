extends RigidBody


# export(int) var walk_force = 30
# export(int) var fly_force = 30
# export(int) var thrust_force = 20
# export(int) var constant_multiplier = 20
export(bool) var lock_rotation_to_planet = false
export(bool) var lock_rotation_on_collision = false

export(float) var thrust_scale = 1.0
export(Dictionary) var thrust_values = {
	"big": 10.0,
	"medium": 2.5,
	"small": 0.5,
}
var inputs = {
	"movement_forward": {"type": "thrust", "direction": "-z", "weight": "medium"},
	"movement_backward": {"type": "thrust", "direction": "z","weight": "medium"},
	"movement_left": {"type": "thrust", "direction": "-x", "weight": "medium"},
	"movement_right": {"type": "thrust", "direction": "x","weight": "medium"},
	#"movement_left_2": {"type": "thrust", "direction": "z", "weight": "medium"},
	#"movement_right_2": {"type": "thrust", "direction": "-z","weight": "medium"},
	"throttle_up": {"type": "thrust", "direction": "y", "weight": "big"},
	"throttle_down": {"type": "thrust", "direction": "-y", "weight": "medium"},
	# "throttle_down": {"type": "action", "action": "throttle down"},
	"pitch_up":	{"type": "rotate", "direction": "x"},
	"pitch_down": {"type": "rotate", "direction": "-x"},
	"roll_left": {"type": "rotate", "direction": "y"},
	"roll_right": {"type": "rotate", "direction": "-y"},
	"yaw_left":	{"type": "rotate", "direction": "z"},
	"yaw_right": {"type": "rotate", "direction": "-z"},
	"reset": {"type": "action", "action": "reset"},
}
export(float) var throttle_sensetivity = 1.0
export(float) var rotate_sensetivity = 1.0
export(bool) var no_world = false

var gravity_direction: Vector3
#planets will set this value for you (check the planet script)
var planet_name: String
# var grounded: bool = false
var rotation_momentum = Vector3(0, 0, 0)
var delta_ = 0
var throttle: float = 0.0

var beginpos: Basis
var beginrot: Vector3
var rootnode: Node = null
var inside_soi: bool

func _ready():

	if not no_world:
		rootnode = get_node("/root/space_map")
		var initplanet = rootnode.get_node(ProjectSettings.get_setting("Game/Initial_Planet"))
		
		_calc_gravity_direction(initplanet)
		_on_player_body_entered(initplanet, "_ready")

	#rotate_sensetivity /= 100
	rotate_sensetivity *= 3
	
	beginpos = global_transform.basis
	beginrot = rotation_degrees

func apply_thrust(delta, direction, weight):
	# weights: big, medium, small
	var thrust = thrust_values[weight]

	# inverse thrust if direction is negative
	var inverse = false
	if direction[0] == "-":
		inverse = true
		direction = direction[1]

	# get impulse on correct axis
	var impulse = Vector3(0, 0, 0)
	if direction == "x":
		impulse = global_transform.basis.x
	if direction == "y":
		impulse = global_transform.basis.y
	if direction == "z":
		impulse = global_transform.basis.z

	apply_impulse(Vector3(0,0,0), impulse * thrust * thrust_scale * delta * (-1 if inverse else 1))
	# GOTTA REWORK THIS!!!! (prob met pos += momentum variable)

func rotate_vessel(delta, direction):
	# rotates the vessel in the given direction
	# inverse if needed
	var inverse = false
	if direction[0] == "-":
		inverse = true
		direction = direction[1]
	
	var rotation = Vector3(0,0,0)
	if direction == "x":
		rotation.x = (-1 if inverse else 1)
	if direction == "y":
		rotation.y = (-1 if inverse else 1)
	if direction == "z":
		rotation.z = (-1 if inverse else 1)
		
	#rotation_degrees += rotation * delta
	rotate_object_local(rotation, rotate_sensetivity * delta)

func _process(delta):
	delta_ = delta
	for type in inputs:
		if Input.is_action_pressed(type):
			if inputs[type]["type"] == "thrust":
				apply_thrust(delta_, inputs[type]["direction"], inputs[type]["weight"])
			if inputs[type]["type"] == "rotate":
				rotate_vessel(delta_, inputs[type]["direction"])
			if inputs[type]["type"] == "action":
				if inputs[type]["action"] == "throttle up":
					throttle = (throttle + throttle_sensetivity/100 if throttle + throttle_sensetivity/100 <= 1.0 else 1.0)
				if inputs[type]["action"] == "throttle down":
					throttle = (throttle - throttle_sensetivity/100 if throttle - throttle_sensetivity/100 >= 0.0 else 0.0)
				if inputs[type]["action"] == "reset":
					global_transform.basis = beginpos
					rotation_degrees = beginrot
					rotation_momentum = Vector3(0,0,0)
					linear_velocity = Vector3(0,0,0)

	if not planet_name == "space":
		#_calc_gravity_direction(planet_name)
		pass
					
func _integrate_forces(state):
	_walk_around_planet(state)
	
func _calc_gravity_direction(planet):
	#print(typeof(get_parent().get_node(planet)))
	gravity_direction = (planet.global_transform.origin - global_transform.origin).normalized()

func _walk_around_planet(state):
	# allign the players y-axis (up and down) with the planet's gravity direciton:
	if lock_rotation_to_planet:
		state.transform.basis.y = -gravity_direction

func set_planet_name(n):
	print ("setting new planet: ", n)
	planet_name = n
	
func _on_player_body_entered(body, comment = ''):
	if rootnode.get_node(body.name).get_node("Surface").get_name() == "Surface":
		if lock_rotation_on_collision:
			transform.basis.y = -gravity_direction
		# grounded = true
		print(comment)
		# print("grounded: ",grounded)
		if body:
			print("body: ",body.name)

func _on_player_body_exited(body):
	if rootnode.get_node(body.name).get_node("Surface").get_name() == "Surface":
		print("")
		# print("not grounded: ",grounded)
		# grounded = false
