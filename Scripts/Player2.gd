extends KinematicBody

export var speed = 4
var skill1 = false
var skill2 = false
var skill3 = false
var can_move = false
var can_attack = false
var max_level = 12
var max_hp = 100
var current_hp
var percentage_hp
onready var hp_bar = $Viewport/HPBar
onready var exp_bar = $Viewport/ExpBar
onready var level_text = $Viewport/Label
var level = 1
var poptext = preload("res://Scenes/PopText.tscn")
var damage = 4

var begin = Vector3()
var end = Vector3()
var direction = Vector3()
var path = []
var blink_dist = 5

var state
enum{IDLE,RUN,ATTACK,ATTACK1,ATTACK2,ATTACK3}

var anim = IDLE
var experience = 0.0

var target = null
var velocity = Vector3.ZERO
var deathcounter = preload("res://Scenes/DeathScene.tscn")
var levelupfx = preload("res://Scenes/LevelUpfx.tscn")
var respawnfx = preload("res://Scenes/ReSpawnfx.tscn")

onready var animate = $Char/AnimationTree
onready var Skill1 = get_node("/root/World/UI/Control/VBoxContainer/Skill1")
onready var Skill2 = get_node("/root/World/UI/Control/VBoxContainer/Skill2")
onready var Skill3 = get_node("/root/World/UI/Control/VBoxContainer/Skill3")
onready var Skill1Progress = get_node("/root/World/UI/Control/VBoxContainer/Skill1/Skill1Progress")
onready var Skill2Progress = get_node("/root/World/UI/Control/VBoxContainer/Skill2/Skill2Progress")
onready var Skill3Progress = get_node("/root/World/UI/Control/VBoxContainer/Skill3/Skill3Progress")
onready var Skill1Time = get_node("/root/World/UI/Control/VBoxContainer/Skill1/Label")
onready var Skill2Time = get_node("/root/World/UI/Control/VBoxContainer/Skill2/Label")
onready var Skill3Time = get_node("/root/World/UI/Control/VBoxContainer/Skill3/Label")
onready var mousefilter = get_node("/root/World/UI/Control")
onready var player = get_node("/root/World/PlayerNav/Player")
onready var playernav = get_node("/root/World/PlayerNav")
onready var camera = get_node("/root/World/Camera")
onready var marker = get_node("/root/World/Marker")
onready var spawn = get_node("/root/World/SpawnLookAt")
onready var selectmarker = get_node("/root/World/SelectMarker")
onready var markeranim = get_node("/root/World/Marker/AnimationPlayer")



func _ready():
	state = IDLE
	current_hp = max_hp
	
func _physics_process(delta):
	animate_state()
	move(delta)

	if skill1:
		skill1_active()
	if skill2:
		skill2_active()
	if skill3:
		skill3_active()

func move(delta):
	
	if can_attack:
		can_move = false
		change_state(ATTACK)
		speed = 0
	
	if path.size() > 1:
		
		var to_walk = delta * speed
		var to_watch = -transform.basis.z
		while to_walk > 0 and path.size() >= 2:
			var pfrom = path[path.size() - 1]
			var pto = path[path.size() - 2]
			to_watch = (pto - pfrom).normalized()
			var d = pfrom.distance_to(pto)
			
			if d <= to_walk:
				path.remove(path.size() - 1)
				to_walk -= d
				if can_move:
					change_state(IDLE)
					can_attack= false
					speed = 6
					
			else:
				path[path.size() - 1] = pfrom.linear_interpolate(pto, to_walk / d)
				to_walk = 0
				if can_move:
					change_state(RUN)
					can_attack = false
					speed = 6
				
				
		var atpos = path[path.size() - 1]
		var atdir = to_watch
		atdir.y = 0
		var rotTransform
		var thisRotation
		var t = transform
		t.origin = atpos
		rotTransform = t.looking_at(atpos + atdir,Vector3.UP) 
		thisRotation = Quat(t.basis.orthonormalized()).slerp(rotTransform.basis.orthonormalized(), delta * 6.0)
		transform = Transform(thisRotation,t.origin)
			

		if path.size() < 1:
			path = []
			speed = 0
			can_attack = false
			
			
	else:
		can_move = true
		can_attack = false




func _unhandled_input(event):
	if (event is InputEventMouseButton and Input.is_mouse_button_pressed(1)) or (event is InputEventMouseMotion and Input.is_mouse_button_pressed(1)):
		if can_move:
			var from = camera.project_ray_origin(event.position)
			var to = from + camera.project_ray_normal(event.position) * 1000
			var p = playernav.get_closest_point_to_segment(from, to)
			begin = playernav.get_closest_point(player.get_translation())
			end = p
			marker.transform.origin = end
			markeranim.play("anim")
			_update_path()
			
		

func _update_path():
	var p = playernav.get_simple_path(begin, end, true)
	path = Array(p)
	path.invert()
	speed = 6
	can_attack = false
	
	
func skill1_finish():
	mousefilter.set_mouse_filter(2) 
	speed = 6
	can_move = true
	change_state(IDLE)

func skill2_finish():
	mousefilter.set_mouse_filter(2) 
	change_state(IDLE)

func skill3_finish():
	mousefilter.set_mouse_filter(2) 
	change_state(IDLE)


func change_state(new_state):
	state = new_state
	match state:
		IDLE:
			anim = IDLE
			
		RUN:
			anim = RUN

		ATTACK:
			anim = ATTACK

		ATTACK1:
			anim = ATTACK1

		ATTACK2:
			anim = ATTACK2

		ATTACK3:
			anim = ATTACK3
			
	
func animate_state():
	animate["parameters/state/current"]=anim
	
func skill1_active():
	Skill1Time.set_text("%01d" % round($Skill1.time_left))
	Skill1Progress.set_value($Skill1.time_left)
	if round($Skill1.time_left) < 1:
		Skill1Time.visible = false
		
func skill2_active():
	Skill2Time.set_text("%01d" % round($Skill2.time_left))
	Skill2Progress.set_value($Skill2.time_left)
	if round($Skill2.time_left) < 1:
		Skill2Time.visible = false

	
func skill3_active():
	Skill3Time.set_text("%01d" % round($Skill3.time_left))
	Skill3Progress.set_value($Skill3.time_left)
	if round($Skill3.time_left) < 1:
		Skill3Time.visible = false


func _on_Skill1_timeout():
	skill1 = false
	Skill1.set_disabled(false)
	Skill1.set_pressed(false)
	
	
func _on_Skill2_timeout():
	skill2 = false
	Skill2.set_disabled(false)
	Skill2.set_pressed(false)
	

func _on_Skill3_timeout():
	skill3 = false
	Skill3.set_disabled(false)
	Skill3.set_pressed(false)

func _on_Skill1_pressed():
	$Skill1Range.visible = !$Skill1Range.visible
	if $Skill1Range.visible == true:
		$Skill1Area.set_ray_pickable(true)
	else:
		$Skill1Area.set_ray_pickable(false)
	
func _on_Skill2_pressed():
	skill2 = true
	speed = 0
	mousefilter.set_mouse_filter(0) 
	$Skill2.start()
	Skill2Time.visible = true
	Skill2.set_disabled(true)
	change_state(ATTACK2)

func _on_Skill3_pressed():
	skill3 = true
	speed = 0
	mousefilter.set_mouse_filter(0) 
	$Skill3.start()
	Skill3Time.visible = true
	Skill3.set_disabled(true)
	change_state(ATTACK3)

# warning-ignore:unused_argument
# warning-ignore:unused_argument
# warning-ignore:unused_argument
# warning-ignore:unused_argument
# warning-ignore:unused_argument
# warning-ignore:shadowed_variable
# warning-ignore:unused_argument
func _on_Skill1Area_input_event(camera, event, click_position, click_normal, shape_idx):
	if (event is InputEventMouseButton and Input.is_mouse_button_pressed(1)): 
		speed = 12
		can_move = false
		skill1 = true
		$Skill1.start()
		$Skill1Range.visible = false
		Skill1Time.visible = true
		Skill1.set_disabled(true)
		mousefilter.set_mouse_filter(0) 
		$Skill1Area.set_ray_pickable(false)
		change_state(ATTACK1)

func experience_counter():
	experience += 1.0
	exp_bar.value = experience
	if exp_bar.value >= 100 and level < max_level:
		experience = 0
		level_counter()
		
func regen():
	current_hp += current_hp * 0.05
	HPBarUpdate()
	if current_hp >= max_hp:
		current_hp = max_hp
	
		
func level_counter():
	level += 1.0
	level_text.set_text(str(level))
	var lvlfx = levelupfx.instance()
	$Effects.add_child(lvlfx)
	yield(get_tree().create_timer(0.5),"timeout")
	$Effects.get_child(0).queue_free()

# warning-ignore:shadowed_variable
func onHit(damage):
	current_hp -= damage
	HPBarUpdate()
	var text = poptext.instance()
	text.amount = damage
	text.type = "Damage"
	$Viewport.add_child(text)
	if current_hp <= 0:
		self.visible = false
		set_physics_process(false)
		set_process_unhandled_input(false)
		path = []
		mousefilter.visible = false
		self.transform.origin = get_node("/root/World/Spawn").transform.origin
		get_node("/root/World/Camera").set_physics_process(false)
		var countdown = deathcounter.instance()
		get_node("/root/World").add_child(countdown)
		
	
func HPBarUpdate():
	percentage_hp = int((float(current_hp)/max_hp) * 100)
	hp_bar.value = percentage_hp
	if percentage_hp >= 60:
		hp_bar.set_tint_progress("08db15")
	elif percentage_hp <= 60 and percentage_hp >= 25:
		hp_bar.set_tint_progress("e1be32")
	else:
		hp_bar.set_tint_progress("e11e1e")
		

func _on_Attack_body_entered(body):
	if body.is_in_group("towerb") and selectmarker.visible == true:
		can_move = false
		can_attack = true
		look_at(body.global_transform.origin,Vector3.UP)
		
		
func _on_Attack_body_exited(body):
	if body.is_in_group("towerb"):
		can_move = true
		can_attack = false
		change_state(IDLE)
		
		
func _on_Hit_body_entered(body):
	if body.is_in_group("towerb"):
		body.onHit(damage)
		
		
func _Respawn():
	change_state(IDLE)
	can_attack = false
	get_node("/root/World/Camera").set_physics_process(true)
	set_process_unhandled_input(true)
	mousefilter.visible = true
	current_hp = max_hp
	Skill1Time.visible = false
	Skill2Time.visible = false
	Skill3Time.visible = false
	Skill1Progress.set_value(0)
	Skill2Progress.set_value(0)
	Skill3Progress.set_value(0)
	Skill1.set_pressed(false)
	Skill2.set_pressed(false)
	Skill3.set_pressed(false)
	look_at(spawn.global_transform.origin,Vector3.UP)
	$Skill1Range.visible = false
	$Skill1Area.set_ray_pickable(false)
	self.visible = true
	set_physics_process(true)
	HPBarUpdate()
	var spawnfx = respawnfx.instance()
	$Effects.add_child(spawnfx)
	yield(get_tree().create_timer(1.0),"timeout")
	$Effects.get_child(0).queue_free()


#Call method track in animationplayer under Char node
func attack():
	$Hit/CollisionShape.set_disabled(false)
func not_attack():
	$Hit/CollisionShape.set_disabled(true)
