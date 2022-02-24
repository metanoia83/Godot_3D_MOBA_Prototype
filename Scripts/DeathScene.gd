extends Control

var ms = 0
var s = 10
var m = 0
onready var Player = get_node("/root/World/PlayerNav/Player")

func _ready():
	pass

# warning-ignore:unused_argument
func _process(delta):
	
	if ms < 0:
		s -= 1
		ms = 9
	if s <= 0:
		$Countdown.visible = false
		Player._Respawn()
		queue_free()
		
		
	$Countdown.set_text("Respawning in " + "%02d" % s + " seconds!" )

func _on_ms_timeout():
	ms -= 1
