extends Spatial


func _on_Mtimer_timeout():
	$Marker.visible = false
	print("timeout")
	
	
func _on_Terrain_input_event(camera, event, click_position, click_normal, shape_idx):
	if (event is InputEventMouseButton and Input.is_mouse_button_pressed(1)):
		$Marker.transform.origin = click_position
		$Marker.visible = true
		$Mtimer.start()
		$Player.target = click_position
		$Player/RayCast.enabled = false
		$Player/RayCast2.enabled = false
		$TurretMarker.visible = false
		
	elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(1):
		$Marker.transform.origin = click_position
		$Marker.visible = true
		$Mtimer.start()
		$Player.target = click_position
		$Player/RayCast.enabled = false
		$Player/RayCast2.enabled = false


func _on_StaticBody_input_event(camera, event, click_position, click_normal, shape_idx):
	if (event is InputEventMouseButton and Input.is_mouse_button_pressed(1)):
		$Player.target = get_object_under_mouse().collider.global_transform.origin
		$Player/RayCast.enabled = true
		$Player/RayCast2.enabled = true
		$TurretMarker.global_transform.origin = get_object_under_mouse().collider.global_transform.origin
		$TurretMarker.visible = true
		
func get_object_under_mouse():
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_from = $Camera.project_ray_origin(mouse_pos)
	var ray_to = ray_from + $Camera.project_ray_normal(mouse_pos) * 1000
	var space_state = get_world().direct_space_state
	var selection = space_state.intersect_ray(ray_from, ray_to)
	return selection

func _on_MinionB_input_event(camera, event, click_position, click_normal, shape_idx):
	if (event is InputEventMouseButton and Input.is_mouse_button_pressed(1)):
		#$Player.target = get_object_under_mouse().collider.global_transform.origin
		$Mtimer.start()
		$TurretMarker.global_transform.origin = get_object_under_mouse().collider.global_transform.origin
		$TurretMarker.visible = true



