extends Node2D

var cutout:=preload("res://sprites/tp_bar_cutout.png")

func _draw():
	draw_texture(cutout,Vector2(40,42))
	update()
