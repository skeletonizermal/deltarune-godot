extends Camera2D


var shake_step:=0

func _process(delta):
	match shake_step:
		5:
			position=Vector2(-4,-4)
		2:
			position=Vector2(4,4)
		3:
			position=Vector2(-3,-3)
		4:
			position=Vector2(2,2)
		0:
			position=Vector2(0,0)
	if shake_step>=0:
		shake_step-=1


func _on_soul_hurt():
	shake_step=5


func _on_soul_ground_pound():
	if shake_step<3:
		shake_step=3
