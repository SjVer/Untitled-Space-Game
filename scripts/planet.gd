tool
extends StaticBody

# EXPORTING
export(float) var rotational_period
export(Vector3) var rotational_vector
export(bool) var lock_rotation_to_parent

export(int) var orbital_height setget oh_set, oh_get
export(float) var orbital_period
export(Vector3) var orbital_vector
export(bool) var show_orbit setget so_set, so_get
export(Color) var orbit_color setget oc_set, oc_get

# SETGETers
# show_orbit
var orbit: CSGTorus
func so_set(new):
	show_orbit = new
	if new and Engine.editor_hint:
		orbit = CSGTorus.new()
		orbit.name = "orbit_torus"
		orbit.sides = 64
		orbit.ring_sides = 4
		orbit.smooth_faces = true
		if not get_parent() == null:
			orbit.translation = -translation
			#orbit.inner_radius = translation.distance_to(get_parent().translation)
		else:
			orbit.translation = Vector3(0,0,0)
			#orbit.inner_radius = translation.distance_to(Vector3(0,0,0))
		orbit.inner_radius = orbital_height
		orbit.outer_radius = orbit.inner_radius + ProjectSettings.get_setting("Game/orbit_indicator_thickness")
		orbit.material = SpatialMaterial.new()
		orbit.material.albedo_color = orbit_color
		orbit.material.flags_unshaded = true
		add_child(orbit)
	else:
		for child in get_children():
			if "orbit_torus" in child.name:
				remove_child(child)
				child.queue_free()
func so_get():
	return show_orbit
# orbit_color
func oc_set(new: Color):
	orbit_color = new
	if not orbit == null:
		orbit.material.albedo_color = new
func oc_get():
	return orbit_color
# orbit_height
func oh_set(new):
	orbital_height = new
	translation = Vector3(0, 0, -new)
	so_set(false)
	so_set(true)
func oh_get():
	return orbital_height


var playername: String
var playernode: Node

func _ready():
	#print("planet.gd line 6 : (nodepath) : ",playersetting)
	#print("planet.gd line 7 : (name) : ",playersetting.get_name(playersetting.get_name_count()-1))
	#playername = playersetting.get_name(playersetting.get_name_count()-1)
	var sett = ProjectSettings.get_setting("Game/player_name")
	playernode = get_tree().get_child(0).get_node(sett)
	playername = playernode.name

func _on_Area_body_entered(body):
	if body.name == playername:
		print(get_parent().name, " setting planet name to ", get_parent().name)
		body.set_planet_name(get_parent().name)
		body._on_player_body_entered(self)
		
		
func _on_Area_body_exited(body):
	if body.name == playername:
		print(name, " setting planet name to space (exited)")
		body.set_planet_name("space")
		body._on_player_body_exited(self)
