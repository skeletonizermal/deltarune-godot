extends KinematicBody2D
class_name BulletBase



export var damage:=10
export var grazepoints:=0.0
export var timepoints:=0.0
var grazed:=false
var target:=0
var grazetimer:=0
var active := true
var updateimageangle := 0
export var destroy_on_hit:=false
export var destory_on_parry:=false
enum types {
	WHITE,
	GREY,
	AQUA,
	ORANGE,
	GREEN,
}
export(types) var bullet_type

onready var soul:=get_node("../soul")
var soul_touching:=false

func _on_Area2D_body_entered(body):
	soul=body
	soul_touching=true


var a:=false

func _ready():
	$Tween.interpolate_property(self,"position",position,position+Vector2(146,0),3,Tween.TRANS_CUBIC,Tween.EASE_IN)
	$Tween.start()
	soul.connect("die",self,"soul_die")

func soul_die():
	queue_free()

#func _process(delta):
#	var temp=position.angle_to_point(get_node("../soul").position)
#	position+=Vector2(-cos(temp),-sin(temp))

var touching_grazebox:=false
var grazebox:Area2D

func _process(delta):
	if not grazed and touching_grazebox and not Global.inv_frames:
		grazed=true
		Global.tensionheal((grazepoints * Global.grazetpfactor))
		grazebox.graze_timer=10
		grazebox.get_node("Sprite").visible=true
		grazebox.get_node("AudioStreamPlayer").stop()
		grazebox.get_node("AudioStreamPlayer").play()
	if grazed and touching_grazebox and not Global.inv_frames:
		Global.tensionheal((grazepoints/30.0 * Global.grazetpfactor * (1.25 if soul.ground_pound_delay>0 else 1.0)))
		if grazebox.graze_timer>=0 and grazebox.graze_timer<3:
			grazebox.graze_timer=3
		if grazebox.graze_timer<2:
			grazebox.graze_timer=2
	if soul_touching:
		if bullet_type==types.WHITE:
			soul.damage(self)
		if bullet_type==types.AQUA:
			if soul.moving:
				soul.damage(self)
		if bullet_type==types.ORANGE:
			if not soul.moving:
				soul.damage(self)
		if destroy_on_hit:
			queue_free()

func _on_Tween_tween_completed(object, key):
	if a:
		a=false
		$Tween.interpolate_property(self,"position",position,position+Vector2(146,0),3,Tween.TRANS_CUBIC,Tween.EASE_IN_OUT)
		$Tween.start()
	else:
		$Tween.interpolate_property(self,"position",position,position+Vector2(-146,0),3,Tween.TRANS_CUBIC,Tween.EASE_IN_OUT)
		$Tween.start()
		a=true


func _on_Area2D_area_entered(area):
	grazebox=area
	touching_grazebox=true


func _on_Area2D_area_exited(area):
	touching_grazebox=false


func _on_Area2D_body_exited(body):
	soul_touching=false
