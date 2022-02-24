extends Position3D


onready var label = get_node("Label")
onready var tween = get_node("Tween")
var type = ""
var velocity = Vector2()
var amount = 0

func _ready():
	label.set_text(str(amount))
	match type:
		"Heal":
			label.set("custom_colors/font_color",Color("3ac21e"))
		"Damage":
			label.set("custom_colors/font_color",Color("ff2a00"))
	
	randomize()
	var side_movement = randi() % 41 - 20
	velocity = Vector2(side_movement, 50)
	
	tween.interpolate_property(label, "rect_scale", Vector2(0.3,0.3), Vector2(0.7,0.7), 0.2,Tween.TRANS_LINEAR,Tween.EASE_OUT)
	tween.interpolate_property(label, "rect_scale", Vector2(0.7,0.7), Vector2(0.1,0.1), 0.5,Tween.TRANS_LINEAR,Tween.EASE_OUT, 0.3)
	tween.start()

func _on_Tween_tween_all_completed():
	self.queue_free()

func _process(delta):
	label.rect_position -= velocity * delta
