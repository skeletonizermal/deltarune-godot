extends Control

var font:= preload("res://some_fonts/font.tres")

func _draw():
	draw_char(Global.font,Vector2(100,100),'a','')

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
