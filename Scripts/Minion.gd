extends KinematicBody

var path = []
var path_node = 0
var speed = 4
onready var nav = get_parent()
onready var target = get_node("/root/World/MOBAmap/MainTowerB")
var poptext = preload("res://Scenes/PopText.tscn")
var max_hp = 50
var current_hp
var percentage_hp
onready var hp_bar = $Viewport/HPBar
var damage = 2

var move = true
var attack = false

var state
enum{IDLE,RUN,ATTACK1,ATTACK2,ATTACK3}

var anim = IDLE

onready var animate = $Char/AnimationTree

func _ready():
	state = IDLE
	current_hp = max_hp

func _on_Area_body_entered(body):
	if body.is_in_group("towerb"):# or body.is_in_group("midturrets") :
		move = false
		attack = true
		speed = 0
		
func _on_Area_body_exited(body):
	if body.is_in_group("towerb"):
		attack = false
		move = true
		speed = 4
		
# warning-ignore:unused_argument
func _physics_process(delta):
	animate_char()

	if move == true:
		attack = false
		change_state(RUN)
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
# warning-ignore:return_value_discarded
			move_and_slide(direction.normalized() * speed, Vector3.UP)


func move_to(target_pos):
	path = nav.get_simple_path(global_transform.origin, target_pos)
	path_node = 0
	change_state(RUN)

func _on_Timer_timeout():
	if move == true:
		move_to(target.global_transform.origin)
		

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
	
func animate_char():
	animate["parameters/state/current"]=anim


# warning-ignore:shadowed_variable
func onHit(damage):
	current_hp -= damage
	HPBarUpdate()
	var text = poptext.instance()
	text.amount = damage
	text.type = "Damage"
	$Viewport.add_child(text)
	if current_hp <= 0:
		queue_free()
		
func HPBarUpdate():
	percentage_hp = int((float(current_hp)/max_hp) * 100)
	hp_bar.value = percentage_hp
	if percentage_hp >= 60:
		hp_bar.set_tint_progress("08db15")
	elif percentage_hp <= 60 and percentage_hp >= 25:
		hp_bar.set_tint_progress("e1be32")
	else:
		hp_bar.set_tint_progress("e11e1e")
	
	
func _on_Hit_body_entered(body):
	if body.is_in_group("towerb"):
		body.onHit(damage)

# warning-ignore:function_conflicts_variable
#Call method track in animationplayer under Char node
func attack():
	$Hit/CollisionShape.set_disabled(false)
func not_attack():
	$Hit/CollisionShape.set_disabled(true)
