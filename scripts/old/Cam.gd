extends Spatial

export(bool) var clamping = false
export(bool) var lock_rotation_to_craft = false
export(bool) var lock_rotation_to_planet = false
export(float) var vertical_max = 90 
export(float) var vertical_min = -90 
export(float) var vertical_sensitivity = 0.2
export(float) var vertical_acceleration = 20
export(float) var horizontal_sensitivity = 0.2 
export(float) var horizontal_acceleration = 20 
export(float) var zoom_min = 2.0
export(float) var zoom_max = 20
export(float) var zoom_sensitivity = 1.0
export(float, 0, 1) var zoom_speed = 0.75
export(float) var default_zoom = 4.0

var camrot: Vector2 = Vector2(0,0)
var targetnode: Node
onready var playernode: Node = get_node("/root/space_map/Player")
onready var zoomlevel = default_zoom
var destination: float

func _ready():
	targetnode = get_parent()
	set_as_toplevel(true)
	$h/v/defaultzoom/ClippedCamera.add_exception(targetnode)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		camrot.x += -event.relative.x * horizontal_sensitivity
		camrot.y += -event.relative.y * vertical_sensitivity
	if event.is_action_pressed("zoom_in"):
		zoomlevel = clamp(zoomlevel - zoom_sensitivity / 10 * (zoomlevel - zoom_min + 1), sqrt(zoom_min), sqrt(zoom_max)) 
	if event.is_action_pressed("zoom_out"):
		zoomlevel = clamp(zoomlevel + zoom_sensitivity / 10 * (zoomlevel - zoom_min + 1), sqrt(zoom_min), sqrt(zoom_max)) 
		
func _physics_process(delta):

	if lock_rotation_to_craft:
		set_rotation(targetnode.rotation_degrees)
	
	if lock_rotation_to_planet and playernode.inside_soi:
		set_rotation(-(get_parent().get_node(playernode.planet).global_transform.origin - global_transform.origin).normalized())
		

	global_transform.origin = targetnode.global_transform.origin

	if clamping:
		camrot.y = clamp(camrot.y, vertical_min, vertical_max)
	
	$h.rotation_degrees.y = lerp($h.rotation_degrees.y, camrot.x, delta * horizontal_acceleration)
	$h/v.rotation_degrees.x = lerp($h/v.rotation_degrees.x, camrot.y, delta * vertical_acceleration)

	# zoom
	destination = $h/v/defaultzoom.transform.origin.z + zoomlevel * zoomlevel
	$h/v/defaultzoom/ClippedCamera.transform.origin.z = lerp($h/v/defaultzoom/ClippedCamera.transform.origin.z, destination, zoom_speed)
	# $h/v/defaultzoom/ClippedCamera.transform.origin.z = destination
