extends Node


func damage_calculation(target,damage):
	var _tdamage = damage
	var _tdef = Global.battledf[target]
	var _tmaxhp = Global.hero_max_hp[Global.cur_char[target]]
	var _finaldamage = 1
	var _hpthresholda = (_tmaxhp / 5)
	var _hpthresholdb = (_tmaxhp / 8)
	for _di in range(_tdef):
		if (_tdamage > _hpthresholda):
			_tdamage -= 3
		elif (_tdamage > _hpthresholdb):
			_tdamage -= 2
		else:
			_tdamage -= 1
	return max(_tdamage, _finaldamage);

func damage(target:int,damage:int,element:=0):
	if target==4:
		target=Global.random_target()
	if target<3:
		var chartarget=Global.cur_char[target]
		if Global.hero_hp[chartarget]<=0:
			target=Global.random_target()
			chartarget=Global.cur_char[target]
		var _tdamage:=damage
		if target!=-1:
			_tdamage=damage_calculation(target,_tdamage)
			Global.hero_hp[chartarget]-=_tdamage
			if Global.hero_hp[chartarget]<0:
				Global.hero_hp[chartarget]=-floor(float(Global.hero_max_hp[chartarget])/2.0)
	if target==3:
		for i in range(len(Global.cur_char)):
			var chartarget=Global.cur_char[i]
			if Global.hero_hp[i]>=0:
				var tdamage=damage_calculation(target,damage)
				Global.hero_hp[chartarget]-=tdamage
				if Global.hero_hp[chartarget]<0:
					Global.hero_hp[chartarget]=-floor(float(Global.hero_max_hp[chartarget])/2.0)
			


func _on_soul_die():
	$box.visible=false
	$CanvasLayer.visible=false
