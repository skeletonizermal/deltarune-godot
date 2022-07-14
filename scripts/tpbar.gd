extends Node2D


var apparent:=0.0
var current:=0.0
var change:=0
var changetimer:=15
var red := 0
var redtimer = 0
var shake:=0
var hspeed = 13
var tsiner:=0.0
var friction = 1

var flashsiner = 0
var maxed:=false

var bigfont:=preload("res://some_fonts/bigfont.tres")

func _draw():
	print(Global.tension)
	draw_rect(Rect2(43,46.0,19,187),Color("#800000"))
	if (abs((apparent - Global.tension)) < 20):
		apparent=Global.tension
	if (apparent < Global.tension):
		apparent += 20
	if (apparent > Global.tension):
		apparent -= 20
	if (apparent != current):
		changetimer += 1
		if (changetimer > 15):
			if ((apparent - current) > 0):
				current += 2
			if ((apparent - current) > 10):
				current += 2
			if ((apparent - current) > 25):
				current += 3
			if ((apparent - current) > 50):
				current += 4
			if ((apparent - current) > 100):
				current += 5
			if ((apparent - current) < 0):
				current -= 2
			if ((apparent - current) < -10):
				current -= 2
			if ((apparent - current) < -25):
				current -= 3
			if ((apparent - current) < -50):
				current -= 4
			if ((apparent - current) < -100):
				current -= 5
			if (abs((apparent - current)) < 3):
				current = apparent
	if (current > 0):
		if (apparent < current):
			draw_rect(Rect2(43, (46.0 + 187.0), (0.0 + 19), -(((current / 100.0) * 187))),Color.red)
			draw_rect(Rect2(43, (46.0 + 187.0), (0.0  + 19), -(((apparent / 100.0) * 187))),Color("#FFA040"))
		if (apparent > current):
			draw_rect(Rect2(43, (46.0 + 187.0), (0 + 19),  -((apparent / 100.0) * 187)), Color.white)
			if maxed:
				draw_rect(Rect2(43, 46.0, (0 + 19), -(((current / 100.0) * 187))), Color("#ffcf20"))
			else:
				draw_rect(Rect2(43, (46.0 + 187.0), (0 + 19), -(((current / 100.0) * 187))), Color("#FFA040"))
		if (apparent == current):
			if maxed:
				draw_rect(Rect2(43, (46.0 + 187.0), (0 + 19), -(((current / 100.0) * 187))), Color("#ffcf20"))
			else:
				draw_rect(Rect2(43, (46.0 + 187.0), (0 + 19), -(((current / 100.0) * 187))), Color("#FFA040"))
	if (Global.tensionselect > 0):
		tsiner += 1
		var alpha:=(abs((sin((tsiner / 8)) * 0.5)) + 0.2)
		var theight = ((46.0 + 187.0) - ((current / 100.0) * 187.0))
		var theight2 = (theight + ((Global.tensionselect / 100.0) * 187.0))
		if (theight2 > ((46.0 + 187.0))):
			theight2 = ((46.0 + 187.0))
			draw_rect(Rect2(43, theight2, (0 + 19.0), theight), Color(0.25,0.25,0.25,0.7))
		else:
			draw_rect(Rect2(43, theight2, (0 + 19.0), theight), Color(1,1,1,alpha))
	if (apparent > 20 and apparent < 100.0):
		draw_rect(Rect2( 43, 46+187- ((current / 100.0) * 187.0),19.0,2.0),Color.white)
	var tamt = floor(((apparent / 100.0) * 100.0))
	if tamt<100:
		draw_string(bigfont,Vector2(8,136),str(tamt),Color.white)
		draw_string(bigfont,Vector2(13,161),"%",Color.white)
	else:
		maxed=true
		draw_string(bigfont,Vector2(10,136),"M",Color.yellow)
		draw_string(bigfont,Vector2(14,156),"A",Color.yellow)
		draw_string(bigfont,Vector2(18,176),"X",Color.yellow)



func _process(delta):
	match shake:
		4:
			position.x=-4
		3:
			position.x=4
		2:
			position.x=-3
		1:
			position.x=2
		0:
			position.x=0
	if shake>0:
		shake-=1
	update()

func _on_soul_hurt():
	shake=4
