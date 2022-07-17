tool
extends Node


var hero_max_hp:=[90,110,70,70]
var hero_hp:=[90,110,70,70]
var battledf:=[2,2,2]

var cur_char:=[0,1,2]

var grazetpfactor:=1.0
var grazetimefactor:=1.0
var inv_frames:=false
var tension:=0.0
var tensionselect:=0

var font:=preload("res://some_fonts/bigfont.tres")

func random_target():
	var a=[]
	randomize()
	for i in range(len(cur_char)):
		if hero_hp[cur_char[i]]>0:
			a.append(i)
	if len(a)>0:
		return a[randi()%len(a)]
	else:
		return -1

func tensionheal(amount):
	tension+=amount
	if tension>=100:
		tension=100
