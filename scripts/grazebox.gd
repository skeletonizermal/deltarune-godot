extends Area2D

var animation_finished:=true



func _on_AnimationPlayer_animation_started(anim_name):
	animation_finished=false


func _on_AnimationPlayer_animation_finished(anim_name):
	animation_finished=true

var graze_timer:=0

func _process(delta):
	if graze_timer>=0:
		$Sprite.modulate.a=float(graze_timer)/6.0
		$Sprite2.modulate.a=float(graze_timer)/6.0-0.2
	if graze_timer>-10:
		graze_timer-=1
	
