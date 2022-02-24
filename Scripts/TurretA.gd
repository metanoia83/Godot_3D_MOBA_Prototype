extends Spatial

enum {STATE_IDLE, STATE_FIRE}

var state = STATE_IDLE

var damage = 5
var shooting = true
var can_shoot = false

var shoot_time = 0

onready var target = get_tree().get_nodes_in_group("TeamB")
var BULLET = preload("res://Scenes/TurretMissile.tscn")

func _ready():
	$Cannon/Nozzle/RayCast.add_exception($StaticBody)
	pass

func _physics_process(delta):
	
	for i in target:
		if i == null:
			target = get_tree().get_nodes_in_group("TeamB")
	
	if can_shoot:
		aim(delta)
		var length = $Cannon/Nozzle.global_transform.origin.distance_to($Cannon/Nozzle/RayCast.get_collision_point())
		if $Cannon/Nozzle/RayCast.is_colliding() and $Cannon/Nozzle/RayCast.get_collider().is_in_group("TeamB"): 
			$Cannon/Nozzle/Beam.translation= $Cannon/Nozzle.translation + (Vector3(0,(-$Cannon/Nozzle/Beam.scale.y/2),0))
			$Cannon/Nozzle/Beam.scale.y = length + 0.5
			$Cannon/Nozzle/Beam.visible = true
			$Range.visible = true
			shoot_time -= 1
			
		
		
func shoot():
	var bullet = BULLET.instance()
	get_parent().add_child(bullet)
	bullet.global_transform.origin = $Cannon/Nozzle.global_transform.origin


func _on_Area_body_entered(body):
	if body.is_in_group("TeamB"):
		can_shoot = true


# warning-ignore:unused_argument
func aim(delta):
	var shortestDistance = 100
	var nearestEnemy = null
	
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
			$Range.visible = false
			shoot_time = 0

func _on_Area_body_exited(body):
	if body.is_in_group("TeamB"):
		$Cannon/Nozzle/Beam.visible = false
		$Range.visible = false



