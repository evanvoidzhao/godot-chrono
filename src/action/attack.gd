extends Action
class_name Attack

static var s_act_name = "ATTACK"

var attack_range = 1
var attack_damage = 10
var attack_position : Vector2 = Vector2.ZERO
var attack_target = null

func _init():
	act_name = s_act_name
	pre_range = 10
	post_range = 3

