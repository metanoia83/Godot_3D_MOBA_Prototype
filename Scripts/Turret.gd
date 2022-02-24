extends StaticBody

enum {STATE_IDLE, STATE_FIRE}

var state = STATE_IDLE

#var damage = 5
var shooting = true
var can_shoot = false
var alert = false

var shoot_time = 0
onready var Player = get_node("/root/World/PlayerNav/Player/Attack/CollisionShape")

onready var target = get_tree().get_nodes_in_group("TeamA")
onready var marker = get_node("/root/World/Marker")
onready var selectmarker = get_node("/root/World/SelectMarker")
var BULLET = preload("res://Scenes/TurretMissile.tscn")
var poptext = preload("res://Scenes/PopText.tscn")

var max_hp = 50
var current_hp
var percentage_hp
onready var hp_bar = $Viewport/HPBar


func _ready():
	$Cannon/Nozzle/RayCast.add_exception(self)
	current_hp = max_hp

func _physics_process(delta):
	
#	for i in target:
#		if i == null:
#			target = get_tree().get_nodes_in_group("TeamA")
	
	if can_shoot:
		aim(delta)
		var length = $Cannon/Nozzle.global_transform.origin.distance_to($Cannon/Nozzle/RayCast.get_collision_point())
		if $Cannon/Nozzle/RayCast.is_colliding() and $Cannon/Nozzle/RayCast.get_collider().is_in_group("TeamA"):# or $Cannon/Nozzle/RayCast.get_collider().is_in_group("MinionA")): 
			$Cannon/Nozzle/Beam.translation= $Cannon/Nozzle.translation + (Vector3(0,(-$Cannon/Nozzle/Beam.scale.y/2),0))
			$Cannon/Nozzle/Beam.scale.y = length + 0.5
			$Cannon/Nozzle/Beam.visible = true
			shoot_time -= 1
		if $Cannon/Nozzle/RayCast.is_colliding():
			if $Cannon/Nozzle/RayCast.get_collider().is_in_group("PlayerA") and alert == false:
				$Range.material_override.albedo_color = Color("e11e1e") #red

			elif $Cannon/Nozzle/RayCast.get_collider().is_in_group("MinionA"):
				if alert == true:
					$Range.material_override.albedo_color = Color("f9a654") #orange
				elif alert == false:
					$Range.material_override.albedo_color = Color("92f05d") #green
		


func shoot():
	var bullet = BULLET.instance()
	get_parent().add_child(bullet)
	bullet.global_transform.origin = $Cannon/Nozzle.global_transform.origin


func _on_Area_body_entered(body):
	if body.is_in_group("TeamA"):
		can_shoot = true
	if body.is_in_group("PlayerA"):
		$Range.visible = true
		alert = false

# warning-ignore:unused_argument
func aim(delta):
	var shortestDistance = 100
	var nearestEnemy = null
	target = get_tree().get_nodes_in_group("TeamA")
	
	for i in target:
		var distancetoenemy = $Cannon/Nozzle.global_transform.origin.distance_to(i.global_transform.origin)
		if distancetoenemy < shortestDistance:
			shortestDistance = distancetoenemy
			nearestEnemy = i
			
	if (nearestEnemy != null and shortestDistance <= $Area/CollisionShape.get_shape().get_radius()):
		if shoot_time < 0:
			shoot_time = 80
			can_shoot = true
			shoot()
		$Cannon.look_at(nearestEnemy.global_transform.origin, Vector3.UP)
	else:
		nearestEnemy = null
		if nearestEnemy == null:
			$Cannon/Nozzle/Beam.visible = false
			shoot_time = 0

func _on_Area_body_exited(body):
	if body.is_in_group("PlayerA"):
		$Cannon/Nozzle/Beam.visible = false
		$Range.material_override.albedo_color = Color("f9a654")
		alert = true
		$Range.visible = false
		


func _on_Alert_body_entered(body):
	if body.is_in_group("PlayerA"):
		$Range.material_override.albedo_color = Color("f9a654")
		$Range.visible = true
		alert = true
		

func _on_Alert_body_exited(body):
	if body.is_in_group("PlayerA"):
		alert = false
		$Range.visible = false
		$Range.material_override.albedo_color = Color("f9a654")
		
func onHit(damage):
	current_hp -= damage
	HPBarUpdate()
	var text = poptext.instance()
	text.amount = damage
	text.type = "Damage"
	$Viewport.add_child(text)
	if current_hp <= 0:
		queue_free()
		selectmarker.visible = false
		
func HPBarUpdate():
	percentage_hp = int((float(current_hp)/max_hp) * 100)
	hp_bar.value = percentage_hp
	if percentage_hp >= 60:
		hp_bar.set_tint_progress("5396ff")
	elif percentage_hp <= 60 and percentage_hp >= 25:
		hp_bar.set_tint_progress("e1be32")
	else:
		hp_bar.set_tint_progress("e11e1e")


# warning-ignore:unused_argument
# warning-ignore:unused_argument
# warning-ignore:unused_argument
# warning-ignore:unused_argument
func _on_Turret_input_event(camera, event, click_position, click_normal, shape_idx):
	if (event is InputEventMouseButton and Input.is_mouse_button_pressed(1)):
		selectmarker.global_transform.origin = global_transform.origin
		selectmarker.visible = true
		Player.set_disabled(false)
		marker.visible = false
		if selectmarker.visible == true:
			Player.set_disabled(false)

		
func _on_Turret_mouse_exited():
	selectmarker.visible = false
	marker.visible = true
	Player.set_disabled(true)
	alert = false
