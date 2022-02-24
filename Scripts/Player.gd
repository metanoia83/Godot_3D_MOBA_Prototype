extends KinematicBody

export var speed = 6
export var gravity = -5
var skill1 = false
var skill2 = false
var skill3 = false
var moving = false
var can_attack = false

var begin = Vector3()
var end = Vector3()
var path = []
var path_node = 0


var state
enum{IDLE,RUN,ATTACK,ATTACK1,ATTACK2,ATTACK3}

var anim = IDLE

var target
var velocity = Vector3.ZERO
onready var nav = get_parent()

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

func _ready():
	state = IDLE
	#

func skill1_finish():
	mousefilter.set_mouse_filter(2) 
	speed = 6
	can_attack = false
	change_state(IDLE)

func skill2_finish():
	mousefilter.set_mouse_filter(2) 
	speed = 6
	change_state(IDLE)
	

func skill3_finish():
	mousefilter.set_mouse_filter(2) 
	speed = 6
	change_state(IDLE)
	

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

	if target:
		look_at(target, Vector3.UP)
		rotation.x = 0
		velocity = -transform.basis.z * speed
		change_state(RUN)
		if transform.origin.distance_to(target) < 1.5:
			target = null
			velocity = Vector3.ZERO
			change_state(IDLE)
			if path_node < path.size():
				velocity = (path[path_node] - global_transform.origin)
				if velocity.length() < 1:
					path_node += 1
				else:
					move_to(target)
					
	velocity = move_and_slide(velocity, Vector3.UP)


func get_object_under_mouse():
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_from = camera.project_ray_origin(mouse_pos)
	var ray_to = ray_from + camera.project_ray_normal(mouse_pos) * 1000
	var space_state = get_world().direct_space_state
	var selection = space_state.intersect_ray(ray_from, ray_to)
	return selection
	
func _unhandled_input(event):
	if (event is InputEventMouseButton and Input.is_mouse_button_pressed(1)) or (event is InputEventMouseMotion and Input.is_mouse_button_pressed(1)):
		target = get_object_under_mouse().position
		
		
func move_to(target_pos):
	path = nav.get_simple_path(global_transform.origin, target_pos)
	path_node = 0
	
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


func _on_Skill1_timeout():
	skill1 = false
	Skill1.set_disabled(false)
	
	
func _on_Skill2_timeout():
	skill2 = false
	Skill2.set_disabled(false)
	

func _on_Skill3_timeout():
	skill3 = false
	Skill3.set_disabled(false)

func _on_Skill1_pressed():
	$Skill1Range.visible = !$Skill1Range.visible

func _on_Skill2_pressed():
	skill2 = true
	velocity = Vector3.ZERO
	target = null
	mousefilter.set_mouse_filter(0) 
	$Skill2.start()
	Skill2Time.visible = true
	Skill2.set_disabled(true)
	change_state(ATTACK2)

func _on_Skill3_pressed():
	skill3 = true
	set_process(true)
	velocity = Vector3.ZERO
	target = null
	mousefilter.set_mouse_filter(0) 
	#velocity = -transform.basis.z * 4
	#velocity.y = 4
	change_state(ATTACK3)
	$Skill3.start()
	Skill3Time.visible = true
	Skill3.set_disabled(true)



func _on_Skill1Area_input_event(camera, event, click_position, click_normal, shape_idx):
	if (event is InputEventMouseButton and Input.is_mouse_button_pressed(1)):
		can_attack = true
		get_node("/root/World/TurretMarker").visible = true
		get_node("/root/World/TurretMarker").global_transform.origin = get_node("/root/World").get_object_under_mouse().collider.global_transform.origin
		$RayCast.enabled = true
		$RayCast2.enabled = true
		$Skill1Area.set_ray_pickable(true)


func _on_Skill1Area_body_entered(body):
	if body.is_in_group("MinionB") and $Skill1Range.visible == true:
		get_node("/root/World/TurretMarker").visible = true
		get_node("/root/World/TurretMarker").global_transform.origin = body.global_transform.origin
		can_attack = true
		$RayCast.enabled = true
		$RayCast2.enabled = true
		if $RayCast.is_colliding() and $RayCast.get_collider().is_in_group("MinionB"):#) or ($RayCast2.is_colliding() and $RayCast2.collider.is_in_group("MinionB"))):
			speed = 0
			skill1 = true
			$Skill1.start()
			Skill1Time.visible = true
			Skill1.set_disabled(true)
			mousefilter.set_mouse_filter(0) 
			change_state(ATTACK1)
		
