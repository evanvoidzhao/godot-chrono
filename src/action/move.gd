extends Action
class_name Move

static var s_act_name = "MOVE"

var  target_position : Vector2 = Vector2.ZERO

func _init():
	act_name = s_act_name
	pre_range = 1
	post_range = 5
