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
var msg:='"MIX." WHAT A NAME LOL!!!!!!&WE CAN DO THIS. TOO./'
var msgqueue:=PoolStringArray([
	"HM. GET OFF THE COMPUTER&FOR ABOUT A MINUTE. \\s1 ^9^9^9^9^9^9^9^9^9^9^9^9%",
	"WELCOME BACK, NERD.",
	"THIS IS ANOTHER MESSAGE. WOWZA./",
	"THIS MESSAGE WILL CLOSE ITSELF.%",
	'\\s1 NO SKIPPING./',
	"LET'S WAIT 3 SECONDS.\\s1 ^8 &\\s0OKAY. THATS DONE./",
])

#MESSAGE FORMATTING GUIDE
# % - Next message, no input
# / - Wait for input, next message
# /% - Wait for input, close message
# %% - Close message, no input
# ^ - Delay
#	1 - 5 frames, 1/6 seconds
#	2 - 10 frames, 1/3 seconds
#	3 - 15 frames, 0.5 seconds
#	4 - 20 frames, 2/3 seconds
#	5 - 30 frames, 1 second
#	6 - 40 frames, 1 and 1/3 seconds
#	7 - 60 frames, 2 seconds
#	8 - 90 frames, 3 seconds
#	5 - 150 frames, 5 seconds


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

func nextmsg(writer_node):
	writer_node.next_msg()
	msg=msgqueue[0]
	msgqueue.remove(0)
