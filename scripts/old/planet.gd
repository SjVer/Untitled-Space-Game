extends StaticBody

var playername: String
onready var playernode: Node = get_node("/root/space_map/Player")

func _ready():
	var playersetting = ProjectSettings.get_setting("Game/Player")
	#print("planet.gd line 6 : (nodepath) : ",playersetting)
	#print("planet.gd line 7 : (name) : ",playersetting.get_name(playersetting.get_name_count()-1))
	playername = playersetting.get_name(playersetting.get_name_count()-1)

func _on_Area_body_entered(body):
	if body.name == playername:
		body.set_planet_name(name)
		playernode.inside_soi = true
		print("inside soi: ",playernode.inside_soi)
		

func _on_Area_body_exited(body):
	if body.name == playername:
		body.set_planet_name("space")
		playernode.inside_soi = false
		print("inside soi: ",playernode.inside_soi)
