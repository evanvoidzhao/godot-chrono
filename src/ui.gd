extends Control


var target = null

func show_ui(t):
	target = t
	get_node("Panel/TextEdit").text = target
	show()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#if Input.is_action_just_pressed("player_interact"): show()
	pass


func _on_confirm_pressed():
	hide()
	pass # Replace with function body.


func _on_cancel_pressed():
	hide()
	pass # Replace with function body.
