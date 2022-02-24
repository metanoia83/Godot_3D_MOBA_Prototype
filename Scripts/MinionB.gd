extends KinematicBody

var path = []
var path_node = 0
var speed = 4
onready var nav = get_parent()
onready var target = get_node("/root/World/MOBAmap/MainTowerB/Target")

var move = true
var attack = false

var state
enum{IDLE,RUN,ATTACK1,ATTACK2,ATTACK3}

var anim = IDLE

onready var animate = $Char/AnimationTree

func _ready():
	state = IDLE

func _on_Area_body_entered(body):
	if body.is_in_group("towerA"):
		move = false
		attack = true
		speed = 0
		

func _physics_process(delta):
	animate()
	if move == true:
		attack = false
	else:
		attack = true
	if attack == true:
		move = false
		change_state(ATTACK1)
	
	if path_node < path.size():
		var direction = (path[path_node] - global_transform.origin)
		if direction.length() < 1 :
			path_node += 1
		else:
			move_and_slide(direction.normalized() * speed, Vector3.UP)



func move_to(target_pos):
	path = nav.get_simple_path(global_transform.origin, target_pos)
	path_node = 0
	change_state(RUN)

func _on_Timer_timeout():
	if move == true:
		move_to(target.global_transform.origin - Vector3(2,0,-2))
		

func change_state(new_state):
	state = new_state
	match state:
		IDLE:
			anim = IDLE
		RUN:
			anim = RUN
		ATTACK1:
			anim = ATTACK1
		ATTACK2:
			anim = ATTACK2
		ATTACK3:
			anim = ATTACK3
	
func animate():
	animate["parameters/state/current"]=anim



