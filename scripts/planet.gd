tool
extends Spatial


# EXPORTING
export(float) var gravity_strength = 9.81 setget gs_set, gs_get
export(int) var planet_radius = 40 setget pr_set, pr_get
export(Color) var planet_color = Color(0,0,1,1) setget pc_set, pc_get
export(int) var soi_radius = 40 setget sr_set, sr_get

export(float) var rotational_period = 24 setget rp_set, rp_get
export(Vector3) var rotational_vector = Vector3(0,1,0) setget rv_set, rv_get
export(bool) var lock_rotation_to_parent = false

export(int) var orbital_height setget peri_set, peri_get
export(float) var orbital_period = 1 setget op_set, op_get
#export(Vector3) var orbital_vector setget ov_set, ov_get
export(float, -90, 90) var inclination = 0
export(float, -360, 360) var inclination_offset = 0
export(bool) var show_orbit = true setget so_set, so_get
export(Color) var orbit_color = Color(0,0,1,1) setget oc_set, oc_get


# SETGETers
# gravity_strength
func gs_set(new):
	gravity_strength = new
	$Axis/StaticBody/Area.gravity = new
func gs_get():
	return gravity_strength
# planet_radius
func pr_set(new):
	planet_radius = new
	$Axis/StaticBody/MeshInstance.mesh.radius = new
	$Axis/StaticBody/MeshInstance.mesh.height = new * 2
	$Axis/StaticBody/Surface.shape.radius = new
func pr_get():
	return planet_radius
# planet_color
func pc_set(new: Color = Color(0,0,1,1)):
	planet_color = new
	$Axis/StaticBody/MeshInstance.get_surface_material(0).albedo_color = new
func pc_get():
	return planet_color
# soi_radius
func sr_set(new):
	soi_radius = new
	print(get_node_or_null("Axis/StaticBody/Area/SOI"))
	if not get_node_or_null("Axis/StaticBody/Area/SOI") == null:
		$Axis/StaticBody/Area/SOI.shape.radius = planet_radius + new
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
	var actual = show_orbit
	so_set(false)
	orbit_color = new
	so_set(actual)
func oc_get():
	return orbit_color
# orbit_height
func peri_set(new):
	orbital_height = new
	$Axis/StaticBody.translation = Vector3(0, 0, -new)
	$Axis/StaticBody.rotation_degrees = Vector3(0,0,0)
	var actual = show_orbit
	so_set(false)
	so_set(actual)
func peri_get():
	return orbital_height
# orbital_period
func op_set(new):
	orbital_period = new
func op_get():
	return orbital_period
# rotational_vector
func rv_set(new: Vector3):
	rotational_vector = Vector3(
		clamp(new.x, -1, 1),
		clamp(new.y, -1, 1),
		clamp(new.z, -1, 1)
	)
func rv_get():
	return rotational_vector
# rotational_period
func rp_set(new):
	rotational_period = new if new > 0 else 0.1
func rp_get():
	return rotational_period


export(bool) var reset_ref = false setget setthing
func setthing(new):
	add_ref()
	
	
var orbangle: Vector3 = Vector3()
var elapsed_time
var playername: String
var root: Node

func _on_Area_body_entered(body):
	if body.name == playername:
		print(name, " setting planet name to ", name)
		body.set_planet_name(name)
		body._on_player_body_entered(self)

func _on_Area_body_exited(body):
	if body.name == playername:
		print(name, " setting planet name to space (exited)")
		body.set_planet_name("space")
		body._on_player_body_exited(self)

func _ready():
	#set_as_toplevel(true)
	var actual = show_orbit
	so_set(false)
	so_set(actual)
	
	playername = ProjectSettings.get_setting("Game/player_name")
	
	add_ref()
	
func _process(delta):
	if orbit != null and Engine.editor_hint and show_orbit:
#		orbit.rotation_degrees = -self.rotation_degrees
		orbit.translation = self.translation
		if orbit.material.albedo_color != orbit_color:
			var actual = show_orbit
			so_set(false)
			so_set(actual)
	
	if self.translation != Vector3(0,0,0):
		self.translation = Vector3(0,0,0)
		printerr("Not allowed to move root of planet '" + name + "'!")
	
	if elapsed_time == null:
		elapsed_time = 0
	elapsed_time += delta
	
	# rotate planet
#	$Axis/StaticBody.rotation_degrees += rotational_vector / rotational_period * delta
	if lock_rotation_to_parent:
		$Axis/StaticBody.set_rotation(rotational_vector * elapsed_time / rotational_period)
	else:
		$Axis/StaticBody.set_rotation(-$Axis.rotation + rotational_vector * elapsed_time / rotational_period)
	
	# orbit planet
	rotation_degrees = Vector3(inclination, inclination_offset, 0)
	if orbit != null and show_orbit:
		pass
		#orbit.rotation_degrees = rotation_degrees / 2
	
	if orbital_period != 0:
		$Axis.rotation_degrees.y += ProjectSettings.get_setting("Game/Period Multiplier") / 360 / orbital_period * delta
	else:
		$Axis.rotation_degrees.y = 0
	
func add_ref(onlyremove: bool = false) -> void:
	for child in self.get_children():
		if "(ref) " + name in child.name:
			self.remove_child(child)
			child.queue_free()
	
	if onlyremove:
		return
			
	var scene = get_tree().get_edited_scene_root()
	if scene == null:
		push_warning("Failed to add node: No scene open")
		return

	var container = self # scene.get_node("Container")
	if container == null:
		push_warning("No Container node found in current scene")
		return
	
	root = Spatial.new()
	root.name = "(ref) " + name
	
	container.add_child(root)
	root.set_owner(scene)
	$Axis/StaticBody/RemoteTransform.remote_path = root.get_path()
