extends StaticBody

var playername: String
var playernode: Node

func _ready():
	#print("planet.gd line 6 : (nodepath) : ",playersetting)
	#print("planet.gd line 7 : (name) : ",playersetting.get_name(playersetting.get_name_count()-1))
	#playername = playersetting.get_name(playersetting.get_name_count()-1)
	var sett = ProjectSettings.get_setting("Game/player_name")
	playernode = get_tree().root.get_child(0).get_node(sett)
	playername = playernode.name

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
