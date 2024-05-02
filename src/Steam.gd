extends Node
#class_name Network

func _ready():
	# Assign environment for SteamID to Spacewar string 480
	OS.set_environment("SteamAppID", str(480))
	OS.set_environment("SteamGameID", str(480))
	Steam.steamInitEx()
func _process(_delta):
	Steam.run_callbacks()
