extends Control

var font:= preload("res://some_fonts/font.tres")

export var cur_color:Color
var special:=1
export var char_pos:Vector2
export var writing_pos:Vector2
export var rate:int

const portrait_offset = 84

var hspace:=16
var vspace:=36

func draw_char_custom(ch:String,font:Font):
	if special==1:
		if cur_color!=Color.white and cur_color!=Color.black:
			draw_char(font,char_pos+Vector2(1,1),ch,'',Color(1,1,1,0.3)*cur_color)
			draw_char(font,char_pos,ch,'',cur_color)
		else:
			draw_char(font,char_pos+Vector2(1,1),ch,'',Color(0,0,0.5))
			draw_char(font,char_pos,ch,'')
	else:
		draw_char(font,char_pos,ch,'',cur_color)
	char_pos.x+=hspace

var maxi:=0
var halt:=0

var curchar='string[i]'
var nextchar:=''
var nextchar2:=''
var prevchar:=''
var prevchar2:=''

func _draw():
	char_pos=writing_pos
	var string=Global.msg
	var i:=0
	halt=0
	var skipme:bool
	if skip_button_held_down:
		skipme=true
	while i<=maxi:
		var accept:=true
		curchar=string[i]
		nextchar=''
		nextchar2=''
		prevchar=''
		prevchar2=''
		if i<len(string)-1:
			nextchar=string[i+1]
		if i<len(string)-2:
			nextchar2=string[i+2]
		if i>1:
			prevchar=string[i-1]
		if i>2:
			prevchar2=string[i-2]
		if curchar=='&':
			accept=false
			char_pos.x=writing_pos.x
			char_pos.y+=vspace
		if curchar=='/':
			halt=1
			accept=false
			if nextchar=='%':
				halt=2
		if curchar=='%':
			accept=false
			if prevchar=='/':
				halt=2
			if nextchar=='%':
				queue_free()
			elif halt!=2:
				Global.nextmsg()
		if accept:
			draw_char_custom(curchar,Global.font)
		i+=1
	if proceed_button_held_down:
		match halt:
			1:
				Global.nextmsg()
			2:
				queue_free()
	if skipme:
		$Timer.start(0.01)
	

func _ready():
	$Timer.start(0.01)

#get_viewport().set_clear_mode(Viewport.CLEAR_MODE_ALWAYS)
#yield(VisualServer, "frame_post_draw")
#var temp:= get_viewport().get_texture()
#var imgtmp:=temp.get_data()
#imgtmp.lock()
#get_node("Label").text=str(imgtmp.get_pixelv(get_viewport().get_mouse_position())*255)
#imgtmp.unlock()

func _process(delta):
	update()

var skip_button_held_down:=false
var proceed_button_held_down:=false
var automash_timer:=0


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		skip_button_held_down=true
	if event.is_action_released("ui_cancel"):
		skip_button_held_down=false
	if event.is_action_pressed("ui_accept"):
		proceed_button_held_down=true
	if event.is_action_released("ui_accept"):
		proceed_button_held_down=false


func _on_Timer_timeout():
	if maxi<len(Global.msg)-2:
		var cchar:=Global.msg[maxi]
		var nchar:=''
		if maxi<len(Global.msg)-3:
			nchar=Global.msg[maxi+1]
		if cchar=='/':
			halt=1
			$Timer.stop()
		if cchar=='|':
			maxi+=1
		if cchar=='^':
			maxi+=2
			if $Timer.time_left>0.0:
				match int(nchar):
					1:
						$Timer.start($Timer.time_left+5.0/30.0)
					2:
						$Timer.start($Timer.time_left+10.0/30.0)
					3:
						$Timer.start($Timer.time_left+15.0/30.0)
					4:
						$Timer.start($Timer.time_left+20.0/30.0)
					5:
						$Timer.start($Timer.time_left+30.0/30.0)
					6:
						$Timer.start($Timer.time_left+40.0/30.0)
					7:
						$Timer.start($Timer.time_left+60.0/30.0)
					8:
						$Timer.start($Timer.time_left+90.0/30.0)
					9:
						$Timer.start($Timer.time_left+150.0/30.0)
		maxi+=1
		if cchar!='/':
			$Timer.start(max(float(rate)/30.0,0.01))
