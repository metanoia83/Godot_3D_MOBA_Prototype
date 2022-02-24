extends RichTextLabel

var ms = 0
var s = 0
var m = 0
onready var player = get_node("/root/World/PlayerNav/Player")



# warning-ignore:unused_argument
func _process(delta):
	
	if ms > 9:
		s += 1
		ms = 0
		if player.current_hp < player.max_hp:
			player.regen()
	if s > 59:
		m += 1
		s = 0
		
	if ms == 1 and player.level < player.max_level:
		player.experience_counter()
		
	set_text("%02d" % m+":"+"%02d" % s)



func _on_ms_timeout():
	ms += 1
