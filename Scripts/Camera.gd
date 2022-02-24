extends Camera

export var distance = 4.0
export var height = 2.0
const ray_length = 1000


func _ready():
	set_as_toplevel(true)

# warning-ignore:unused_argument
func _physics_process(delta):
	var target = get_node("/root/World/PlayerNav/Player").get_global_transform().origin
	var pos = get_global_transform().origin
	var up = Vector3(0,1,0)

	var offset = pos - target

	offset.z = distance
	offset.y = height
	offset.x = 15
	pos = target + offset
	
	look_at_from_position(pos, target, up)
