tool
extends HBoxContainer

var panel:=preload("res://scenes/char_panel.tscn")

func _ready():
	for i in Global.cur_char:
		var inst:=panel.instance()
		inst.current_hero=i
		add_child(inst)
