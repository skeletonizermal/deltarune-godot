extends KinematicBody2D

signal hurt()

var velocity:=Vector2(0,0)

enum soul_modes {
	RED, #normal movement, nothing special
	ORANGE, #soul can't stop moving, z to dash through bullets(bonus tp)
	YELLOW, #normal movement, shoots projectiles with z. hold down z to shoot a big shot
	GREEN, #soul can't move, but has a shield that rotates with the arrow keys. holding down z will alow the soul to dash in the direction of the shield, allowing it to deflect some projectiles
	AQUA, #soul can only move at half speed, but can parry attacks
	BLUE, #soul has gravity applied to it, can jump. pressing z while mid-air will allow the soul to groundpound
	PURPLE #soul is restricted to one axis of movement but can change between multiple rows.  
}

var soul_mode:int=soul_modes.RED
export(soul_modes) var test_soul_mode

var red_soul_graphic:=preload("res://sprites/red_soul-sheet.png")
var orange_soul_graphic:=preload("res://sprites/spr_heartorange.png")
var blue_soul_graphic:=preload("res://sprites/spr_heartblue.png")
var aqua_soul_graphic:=preload("res://sprites/spr_heartaqua.png")

const parry_frames_max = 30.0

var blue_soul_direction:=Vector2(0,-1) #specifies the "UP" of the blue soul.

export var orange_soul_main_axis_is_up:=false
var orange_soul_slow_down:=0

func change_soul_type(type:int):
	match type:
		soul_modes.RED:
			$Sprite.texture=red_soul_graphic
			soul_mode=soul_modes.RED
			$grazebox/Sprite2.modulate=Color(1.0,0.8,0.8,0.0)
		soul_modes.BLUE:
			$Sprite.texture=blue_soul_graphic
			soul_mode=soul_modes.BLUE
			$grazebox/Sprite2.modulate=Color(0.8,0.8,1.0,0.0)
		soul_modes.AQUA:
			$Sprite.texture=aqua_soul_graphic
			soul_mode=soul_modes.AQUA
			$grazebox/Sprite2.modulate=Color(0.8,1.0,1.0,0.0)
		soul_modes.ORANGE:
			$Sprite.texture=orange_soul_graphic
			soul_mode=soul_modes.ORANGE
			$grazebox/Sprite2.modulate=Color(1.0,0.92,0.8,0.0)
			$CPUParticles2D4.emitting=true
			if orange_soul_main_axis_is_up:
				velocity.y=200
			else:
				velocity.x=200

func _ready():
	change_soul_type(test_soul_mode)

var mem_orange_vel:=Vector2.ZERO

signal ground_pound()
var ground_pound_inv:=false

var orange_charge_frames:=0
var memrot:=0.0

func _physics_process(delta):
	Global.inv_frames=inv_frames
	if not dead:
		velocity=get_input()
		var temp_vel:=velocity
		velocity=move_and_slide(velocity,blue_soul_direction if soul_mode==soul_modes.BLUE else (Vector2(-1,0) if orange_soul_main_axis_is_up else Vector2(0,-1)))
		position=position.round()
		match soul_mode:
			soul_modes.BLUE:
				$Sprite2.region_rect=Rect2(0,0,20,20)
				$Sprite2.offset=Vector2(0,0)
				if blue_soul_direction.y==-1:
					var temp:=velocity.y
					if temp<=-120:
						velocity.y+=6
					if temp>-120 and temp<=-30:
						velocity.y+=9
					if temp>-30 and temp<=15:
						velocity.y+=12
					if temp>15 and temp<240:
						velocity.y+=18
					if temp>=270 and temp<300:
						velocity.y+=30
					if temp>=330:
						ground_pound_inv=true
					else:
						ground_pound_inv=false
					if temp>=300 and temp<330:
						velocity.y+=45
					if temp>=330 and temp<300:
						velocity.y+=60
					if temp_vel.y>=270:
						print(temp_vel)
						if is_on_floor():
							ground_pound_delay=10
							$CPUParticles2D2.emitting=false
							emit_signal("ground_pound")
							$ground_pound.play()
				if ground_pound_delay>0:
					$Sprite2.modulate=Color(1.0,1.0,1.0,(ground_pound_delay/2)*0.1)
					if ground_pound_delay>5:
						ground_pound_inv=true
					else:
						ground_pound_inv=false
					ground_pound_delay-=1
			soul_modes.AQUA:
				if Input.is_action_just_pressed("ui_accept"):
					if parry_attempt_frames<3:
						parry_attempt_frames=3
				$Sprite2.modulate.a=int(parry_frames>0)
				if parry_frames>0:
					$Sprite2.region_rect=Rect2(0,floor(20.0*(float(abs(parry_frames-parry_frames_max))/parry_frames_max)),20,20.0*(float(parry_frames)/parry_frames_max))
					$Sprite2.offset.y=floor(20.0*(float(abs(parry_frames-parry_frames_max))/parry_frames_max))/2
					parry_frames-=1
					$parry_inv_noise.volume_db=linear2db(parry_frames/60.0*0.8)
				else:
					if $parry_inv_noise.playing:
						$parry_inv_noise.stop()
					if $CPUParticles2D3.emitting:
						$CPUParticles2D3.emitting=false
				if parry_attempt_frames>0:
					parry_attempt_frames-=1
			soul_modes.ORANGE:
				var collided:=false
				if orange_soul_main_axis_is_up:
					if abs(velocity.y)>200:
						velocity.y-=10*sign(velocity.y)
				else:
					if abs(velocity.x)>200:
						velocity.x-=10*sign(velocity.x)
				if is_on_wall():
					if orange_soul_main_axis_is_up:
						velocity.y=temp_vel.y*-1.0
					else:
						velocity.x=temp_vel.x*-1.0
				if not orange_soul_nudging and not velocity.is_equal_approx(Vector2.ZERO):
					if orange_soul_main_axis_is_up:
						velocity.x-=sign(velocity.x)*1
					else:
						velocity.y-=sign(velocity.y)*1
				if Input.is_action_just_pressed("ui_accept"):
					mem_orange_vel=velocity
					memrot=$Sprite.rotation
				if Input.is_action_pressed("ui_accept"):
					if velocity.is_equal_approx(Vector2.ZERO):
						orange_charge_frames=min(orange_charge_frames+1,30)
					if orange_soul_main_axis_is_up:
						velocity.y-=10*sign(velocity.y)
						velocity.x*=0.2
					else:
						velocity.x-=10*sign(velocity.x)
					$Sprite2.modulate.a=float(min(orange_charge_frames,15))/15.0*0.5
				if not velocity.is_equal_approx(Vector2.ZERO):
					print(velocity)
					if not $CPUParticles2D4.emitting:
						$CPUParticles2D4.emitting=true
					$Sprite.rotation=atan2(velocity.y,velocity.x)-PI/2.0
					memrot=$Sprite.rotation
				else:
					$Sprite.rotation=memrot
					if $CPUParticles2D4.emitting:
						$CPUParticles2D4.emitting=false
				$Sprite2.rotation=$Sprite.rotation
				$grazebox/Sprite.rotation=$Sprite.rotation
				$grazebox/Sprite2.rotation=$Sprite.rotation
				$CPUParticles2D4.angle=rad2deg($Sprite.rotation)
				if orange_charge_frames==30:
					Input.action_release("ui_accept")
				if Input.is_action_just_released("ui_accept"):
					$Sprite2.modulate.a=0
					var temprot=$Sprite.rotation+PI/2.0
					if orange_soul_main_axis_is_up:
						print(sign(sin($Sprite.rotation)))
						velocity.y=(200+20*min(orange_charge_frames,15))*ceil(abs(sin(temprot)))*sign(sin(temprot))
					else:
						velocity.x=(200+20*min(orange_charge_frames,15))*ceil(abs(cos(temprot)))*sign(cos(temprot))
					orange_charge_frames=0
		moving= velocity!=Vector2(0,0)

var ground_pound_delay:=0
var moving:=false

export var inv_frames:=false

var break_sprite:=preload("res://sprites/spr_heartbreak_0.png")
var dead:=false

var parry_attempt_frames:=0

func damage(source):
	if soul_mode==soul_modes.AQUA:
		if parry_frames==0 and inv_frames==false:
			if parry_attempt_frames>0 or Input.is_action_just_pressed("ui_accept"):
				if parry_possible:
					parry_frames=parry_frames_max
					$parry_inv_noise.play()
					$CPUParticles2D3.emitting=true
	if not inv_frames and not ground_pound_inv and parry_frames==0:
		get_parent().damage(source.target,source.damage,1)
		var sum=0
		for i in Global.cur_char:
			sum+=max(Global.hero_hp[i],0)
		$hurt.play()
		if sum>0:
			inv_frames=true
			$AnimationPlayer.play("blink")
			emit_signal("hurt")
		else:
			pause_mode=Node.PAUSE_MODE_PROCESS
			get_tree().paused=true
			dead=true
			$Sprite2.hide()
			$Sprite.rotation=0
			
			$CPUParticles2D2.hide()
			$CPUParticles2D3.hide()
			$CPUParticles2D4.hide()
			$Sprite.texture=red_soul_graphic
			yield(get_tree().create_timer(0.8),"timeout")
			emit_signal("die")
			yield(get_tree().create_timer(0.5),"timeout")
			$Sprite.texture=break_sprite
			$Sprite.region_enabled=false
			$break.play()
			yield(get_tree().create_timer(1.0),"timeout")
			$CPUParticles2D.emitting=true
			$break2.play()
			$Sprite.hide()
			$grazebox.hide()

signal die()

var orange_soul_nudging:bool

func get_input():
	var out:=Vector2(0,0)
	orange_soul_nudging=false
	if Input.is_action_pressed("ui_right"):
		match soul_mode:
			soul_modes.RED:
				out.x=ceil(Input.get_action_strength("ui_right"))
			soul_modes.AQUA:
				out.x=ceil(Input.get_action_strength("ui_right"))
			soul_modes.BLUE:
				if blue_soul_direction.x!=0:
					out.x=ceil(Input.get_action_strength("ui_right"))
				if blue_soul_direction.y==1:
					if blue_soul_direction.x!=0:
						out.x=ceil(Input.get_action_strength("ui_right"))
					if blue_soul_direction.y==-1 and is_on_floor() and ground_pound_delay==0:
						out.x=-6
			soul_modes.ORANGE:
				if orange_soul_main_axis_is_up and velocity.x<=30 and not Input.is_action_pressed("ui_accept"):
					orange_soul_nudging=true
					velocity.x+=5
					velocity.x=min(velocity.x,30)
	if Input.is_action_pressed("move_right"):
		match soul_mode:
			soul_modes.RED:
				out.x=1
			soul_modes.AQUA:
				out.x=1
			soul_modes.BLUE:
				if blue_soul_direction.y!=0:
					out.x=1
				if blue_soul_direction.x==1:
					if blue_soul_direction.y!=0:
						out.x=1
					if blue_soul_direction.x==-1 and is_on_floor() and ground_pound_delay==0:
						out.x=-6
			soul_modes.ORANGE:
				if orange_soul_main_axis_is_up and velocity.x<=30 and not Input.is_action_pressed("ui_accept"):
					orange_soul_nudging=true
					velocity.x+=5
					velocity.x=min(velocity.x,30)
	if Input.is_action_pressed("ui_left"):
		match soul_mode:
			soul_modes.RED:
				out.x=-ceil(Input.get_action_strength("ui_left"))
			soul_modes.AQUA:
				out.x=-ceil(Input.get_action_strength("ui_left"))
			soul_modes.BLUE:
				if blue_soul_direction.y!=0:
					out.x=-ceil(Input.get_action_strength("ui_left"))
				if blue_soul_direction.x==-1:
					if blue_soul_direction.x!=0:
						out.x=-ceil(Input.get_action_strength("ui_left"))
					if blue_soul_direction.x==-1 and is_on_floor() and ground_pound_delay==0:
						out.x=-6
			soul_modes.ORANGE:
				if orange_soul_main_axis_is_up and velocity.x>=-30 and not Input.is_action_pressed("ui_accept"):
					orange_soul_nudging=true
					velocity.x-=5
					velocity.x=max(velocity.x,-30)
	if Input.is_action_pressed("move_left"):
		match soul_mode:
			soul_modes.RED:
				out.x=-1
			soul_modes.AQUA:
				out.x=-1
			soul_modes.BLUE:
				if blue_soul_direction.y!=0:
					out.x=-1
				if blue_soul_direction.x==-1:
					if blue_soul_direction.y!=0:
						out.x=-1
					if blue_soul_direction.x==-1 and is_on_floor() and ground_pound_delay==0:
						out.x=-6
			soul_modes.ORANGE:
				if orange_soul_main_axis_is_up and velocity.x>=-30 and not Input.is_action_pressed("ui_accept"):
					orange_soul_nudging=true
					velocity.x-=5
					velocity.x=max(velocity.x,-30)
	if Input.is_action_pressed("ui_down"):
		match soul_mode:
			soul_modes.RED:
				out.y=ceil(Input.get_action_strength("ui_down"))
			soul_modes.AQUA:
				out.y=ceil(Input.get_action_strength("ui_down"))
			soul_modes.BLUE:
				if blue_soul_direction.y!=0:
					out.y=ceil(Input.get_action_strength("ui_down"))
				if blue_soul_direction.x==1:
					if blue_soul_direction.y!=0:
						out.y=ceil(Input.get_action_strength("ui_down"))
					if blue_soul_direction.x==-1 and is_on_floor() and ground_pound_delay==0:
						out.y=-6
			soul_modes.ORANGE:
				if not orange_soul_main_axis_is_up and velocity.y<=30 and not Input.is_action_pressed("ui_accept"):
					orange_soul_nudging=true
					velocity.y+=5
					velocity.y=min(velocity.y,30)
	if Input.is_action_pressed("move_down"):
		match soul_mode:
			soul_modes.RED:
				out.y=1
			soul_modes.AQUA:
				out.y=1
			soul_modes.BLUE:
				if blue_soul_direction.x!=0:
					out.y=1
				if blue_soul_direction.y==1:
					if blue_soul_direction.x!=0:
						out.y=1
					if blue_soul_direction.y==-1 and is_on_floor() and ground_pound_delay==0:
						out.y=-6
			soul_modes.ORANGE:
				if not orange_soul_main_axis_is_up and velocity.y<=30 and not Input.is_action_pressed("ui_accept"):
					orange_soul_nudging=true
					velocity.y+=5
					velocity.y=min(velocity.y,30)
	if Input.is_action_pressed("ui_up"):
		match soul_mode:
			soul_modes.RED:
				out.y=-ceil(Input.get_action_strength("ui_up"))
			soul_modes.AQUA:
				out.y=-ceil(Input.get_action_strength("ui_up"))
			soul_modes.BLUE:
				if blue_soul_direction.x!=0:
					out.y=-ceil(Input.get_action_strength("ui_up"))
				if blue_soul_direction.y==-1:
					if blue_soul_direction.x!=0:
						out.y=-ceil(Input.get_action_strength("ui_up"))
					if blue_soul_direction.y==-1 and is_on_floor() and ground_pound_delay==0:
						out.y=-6
			soul_modes.ORANGE:
				if not orange_soul_main_axis_is_up and velocity.y>=-30 and not Input.is_action_pressed("ui_accept"):
					orange_soul_nudging=true
					velocity.y-=5
					velocity.y=max(velocity.y,-30)
	if Input.is_action_pressed("move_up"):
		match soul_mode:
			soul_modes.RED:
				out.y=-1
			soul_modes.AQUA:
				out.y=-1
			soul_modes.BLUE:
				if blue_soul_direction.x!=0:
					out.y=-1
				if blue_soul_direction.y==-1:
					if blue_soul_direction.x!=0:
						out.y=-1
					if blue_soul_direction.y==-1 and is_on_floor() and ground_pound_delay==0:
						out.y=-6
			soul_modes.ORANGE:
				if not orange_soul_main_axis_is_up and velocity.y>=-30 and not Input.is_action_pressed("ui_accept"):
					orange_soul_nudging=true
					velocity.y-=5
					velocity.y=max(velocity.y,-30)
	match soul_mode:
		soul_modes.RED:
			return out*(60 if Input.is_action_pressed("ui_cancel") else 120)
		soul_modes.AQUA:
			return out*(60)
		soul_modes.ORANGE:
			if abs(velocity.x)<1:
				velocity.x=0
			if abs(velocity.y)<1:
				velocity.y=0
			return velocity
		soul_modes.BLUE:
			if blue_soul_direction.y!=0:
				if velocity.y<-1 and blue_soul_direction.y==-1:
					if Input.is_action_just_released("ui_up") and blue_soul_direction.y==-1:
						out.y=-1
				if velocity.y>1 and blue_soul_direction.y==1:
					if Input.is_action_just_released("ui_down") and blue_soul_direction.y==1:
						out.y=1
			if Input.is_action_just_pressed("ui_accept") and not is_on_floor() and (velocity.y/blue_soul_direction.y)>-270 and (velocity.y/blue_soul_direction.y)<120:
				out=blue_soul_direction*-9
				$CPUParticles2D2.emitting=true
			if (velocity.y/blue_soul_direction.y)<-270:
				out.x=0
			if out.y!=0:
				print(out,'OUT')
				return out*Vector2(60 if Input.is_action_pressed("ui_cancel") else 120,30)
			else:
				return Vector2(out.x*(60 if Input.is_action_pressed("ui_cancel") else 120),velocity.y)
				



func _on_Area2D_area_exited(area):
	pass # Replace with function body.


func _on_AnimationPlayer_animation_started(anim_name):
	pass # Replace with function body.


var parry_frames:=0
var parry_possible:=false
var parry_bullets:=[]

func _on_parry_body_entered(body):
	if soul_mode==soul_modes.AQUA:
		parry_bullets.append(body)
		parry_possible=true


func _on_parry_body_exited(body):
	if soul_mode==soul_modes.AQUA:
		parry_bullets.erase(body)
		if parry_bullets.size()==0:
			parry_possible=false


func _on_hit_wall_body_entered(body):
	if orange_soul_main_axis_is_up and soul_mode==soul_modes.ORANGE:
		print('HELLO!',sign(velocity.y))
		velocity.y=sign(velocity.y)*-200


func _on_hit_wall_hor_body_entered(body):
	if not orange_soul_main_axis_is_up and soul_mode==soul_modes.ORANGE:
		print('HELLO!',sign(velocity.x))
		velocity.x=sign(velocity.x)*-200
