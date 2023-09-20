extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	clear_all_level()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_move_pressed():
	clear_all_level()
	$Level2/Move.visible = true
	pass # Replace with function body.


func _on_back_pressed():
	clear_all_level()
	$Level1/MainPanel.visible = true
	pass # Replace with function body.

func clear_all_level():
	var lv1 = $Level1.get_children()
	var lv2 = $Level2.get_children()
	
	for item in lv1:
		item.visible = false
	for item in lv2:
		item.visible = false


func _on_up_pressed():
	get_parent().move_target(Vector2.UP)
	pass # Replace with function body.


func _on_down_pressed():
	get_parent().move_target(Vector2.DOWN)
	pass # Replace with function body.


func _on_left_pressed():
	get_parent().move_target(Vector2.LEFT)
	pass # Replace with function body.


func _on_right_pressed():
	get_parent().move_target(Vector2.RIGHT)
	pass # Replace with function body.


func _on_attack_pressed():
	clear_all_level()
	$Level2/Attack.visible = true
	get_parent().enable_select_tile(true)
	pass # Replace with function body.


func _on_atack_back_pressed():
	clear_all_level()
	$Level1/MainPanel.visible = true
	get_parent().enable_select_tile(false)
	pass # Replace with function body.
