extends Action
class_name Attack

static var s_act_name = "ATTACK"

var attack_range = 0
var attack_damage = 0
var attack_position : Vector2 = Vector2.ZERO

func _init():
	act_name = s_act_name
	pre_range = 3
	post_range = 3

