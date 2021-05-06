tool
extends StaticBody

# EXPORTING
export(int) var planet_radius = 40 setget pr_set, pr_get
export(Color) var planet_color = Color(0,0,1,1) setget pc_set, pc_get
export(int) var soi_radius = 80 setget sr_set, sr_get

export(float) var rotational_period = 1
export(Vector3) var rotational_vector = Vector3(0,1,0)
export(bool) var lock_rotation_to_parent = false

export(int) var orbital_height setget oh_set, oh_get
export(float) var orbital_period
export(Vector3) var orbital_vector setget ov_set, ov_get
export(bool) var show_orbit = false setget so_set, so_get
export(Color) var orbit_color = Color(0,0,1,1) setget oc_set, oc_get

# SETGETers
# planet_radius
func pr_set(new):
	planet_radius = new
	$MeshInstance.mesh.radius = new
	$MeshInstance.mesh.height = new * 2
	$Surface.shape.radius = new
func pr_get():
	return planet_radius
# planet_color
func pc_set(new: Color = Color(0,0,1,1)):
	planet_color = new
	#print_tree_pretty()
	#print(get_child_count())
	$MeshInstance.get_surface_material(0).albedo_color = new
func pc_get():
	return planet_color
# soi_radius
func sr_set(new):
	soi_radius = new
	$Area/CollisionShape.shape.radius = new
func sr_get():
	return soi_radius
# show_orbit
var orbit: CSGTorus
func so_set(new):
	show_orbit = new
	if new and Engine.editor_hint:
		orbit = CSGTorus.new()
		orbit.name = "orbit_torus"
		orbit.sides = 64
		orbit.ring_sides = 4
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
		orbit.material.flags_unshaded = false
		orbit.material.emission_enabled = true
		orbit.material.emission = orbit_color
		orbit.smooth_faces = true
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
	so_set(false)
	orbit_color = new
	so_set(show_orbit)
func oc_get():
	return orbit_color
# orbit_height
func oh_set(new):
	orbital_height = new
	translation = Vector3(0, 0, -new)
	rotation_degrees = Vector3(0,0,0)
	so_set(false)
	so_set(show_orbit)
func oh_get():
	return orbital_height
# orbital_vector
func ov_set(new: Vector3):
	orbital_vector = Vector3(
		clamp(new.x, -1, 1),
		clamp(new.y, -1, 1),
		clamp(new.z, -1, 1)
	)
func ov_get():
	return orbital_vector


var angle: Vector3 = Vector3()
var elapsed_time
var playername: String

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

func _ready():
	#set_as_toplevel(true)
	so_set(false)
	so_set(show_orbit)
	
	change_parent()
	
	playername = ProjectSettings.get_setting("Game/player_name")
	
	angle.x = orbital_vector.x * ProjectSettings.get_setting("Game/Period Multiplier") / 360 / orbital_period
	angle.y = orbital_vector.y * ProjectSettings.get_setting("Game/Period Multiplier") / 360 / orbital_period
	angle.z = orbital_vector.z * ProjectSettings.get_setting("Game/Period Multiplier") / 360 / orbital_period
	
func _process(delta):
	
	if orbit != null and Engine.editor_hint and not show_orbit:
		orbit.rotation_degrees = orbital_vector - rotation_degrees
		orbit.translation = -translation
		if orbit.material.albedo_color != orbit_color:
			so_set(false)
			so_set(show_orbit)
	
	if elapsed_time == null:
		elapsed_time = 0
	elapsed_time += delta
	
	# rotate planet
	rotation_degrees += rotational_vector * delta
	
	# orbit planet
	#if name == "moon" or true:
	#	translation = Vector3(0,0, 0) + Vector3(
	#		orbital_height * cos(orbital_vector.x * elapsed_time),
	#		orbital_height * cos(orbital_vector.y * elapsed_time),
	#		orbital_height * sin(orbital_vector.z * elapsed_time)
	#	) if orbital_vector != Vector3(0,0,0) else Vector3(0,0,-orbital_height)

func change_parent():
	pass
