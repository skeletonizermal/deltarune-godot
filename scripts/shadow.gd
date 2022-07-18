extends Node2D

func _draw():
	draw_char(Global.font,get_parent().char_pos+Vector2(1,1),'M','',(Color(1.0,1.0,1.0,0.3)*get_parent().cur_color) if get_parent().cur_color!=Color.white and get_parent().cur_color!=Color.black else Color.white)

