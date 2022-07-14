tool
extends Control

enum heroes {
	KRIS,
	SUSIE,
	RALSEI,
	NOELLE,
}
export(heroes) var current_hero


var kris_face:=preload("res://sprites/battle_face_kris.png")
var susie_face:=preload("res://sprites/battle_face_susie.png")
var ralsei_face:=preload("res://sprites/battle_face_ralsei.png")
var noelle_face:=preload("res://sprites/battle_face_noelle.png")

var kris_text:=preload("res://sprites/kris_text.png")
var susie_text:=preload("res://sprites/susie_text.png")
var ralsei_text:=preload("res://sprites/ralsei_text.png")
var noelle_text:=preload("res://sprites/noelle_text.png")

func _ready():
	match current_hero:
		heroes.KRIS:
			$face.texture=kris_face
			$name.texture=kris_text
			$ProgressBar.self_modulate=Color.cyan
		heroes.SUSIE:
			$face.texture=susie_face
			$name.texture=susie_text
			$ProgressBar.self_modulate=Color.magenta
		heroes.RALSEI:
			$face.texture=ralsei_face
			$name.texture=ralsei_text
			$ProgressBar.self_modulate=Color.green
		heroes.NOELLE:
			$face.texture=noelle_face
			$name.texture=noelle_text
			$ProgressBar.self_modulate=Color.yellow

func _process(delta):
	$maxhp.text=str(Global.hero_max_hp[current_hero])
	$curhp.text=str(Global.hero_hp[current_hero])
	$ProgressBar.value=ceil(float(Global.hero_hp[current_hero])/float(Global.hero_max_hp[current_hero])*76.0)
	var temp:=float(Global.hero_hp[current_hero])/float(Global.hero_max_hp[current_hero])
	if temp>0.25:
		$curhp.modulate=Color.white
		$maxhp.modulate=Color.white
	if temp<=0.25:
		$curhp.modulate=Color.yellow
		$maxhp.modulate=Color.yellow
	if temp<=0:
		$curhp.modulate=Color.red
		$maxhp.modulate=Color.red
