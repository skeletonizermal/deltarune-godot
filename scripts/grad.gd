extends Node2D

export(GradientTexture2D) var grad

func _draw():
	draw_texture(grad,get_parent().char_pos+Vector2(2,-24))
