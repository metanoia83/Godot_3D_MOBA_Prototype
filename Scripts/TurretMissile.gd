extends Area


var steer_force = 150
var speed = 200

var damage = 10

var velocity = Vector3.ZERO
var accel = Vector3.ZERO
onready var target = get_tree().get_nodes_in_group("TeamA")
var can_shoot = false


func _ready():
	$Timer.start()

func _physics_process(delta):
	
	if target:
		can_shoot = true
	
	for i in target:
		if i == null:
			target = get_tree().get_nodes_in_group("TeamA")
		
	if can_shoot:
		aim(delta)

func aim(delta):
	var shortestDistance = 100
	var nearestEnemy = null
	
	for i in target:
		var distancetoenemy = global_transform.origin.distance_to(i.global_transform.origin)
		if distancetoenemy < shortestDistance:
			shortestDistance = distancetoenemy
			nearestEnemy = i
#			if nearestEnemy.current_hp <= 0:
#				nearestEnemy = target[1]
			
	if (nearestEnemy != null and shortestDistance <= 9):
		var target_location = nearestEnemy.global_transform.origin
		var desired_velocity = (target_location - transform.origin).normalized() * speed
		var steer = (desired_velocity - velocity).normalized() * steer_force
		velocity += steer * delta
		set_as_toplevel(true)
		look_at(nearestEnemy.transform.origin + velocity, Vector3.UP)
		translation += velocity * delta 
	else:
		nearestEnemy = null
		

func _on_TurretMissile_body_entered(body):
	if body.is_in_group("TeamA"):
		body.onHit(damage)
		queue_free()

func _on_Timer_timeout():
	queue_free()

