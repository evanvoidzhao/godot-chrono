extends Node3D
class_name Game

#var player1 : BattlePlayer = null
#var player2 : BattlePlayer = null
var tactics_camera : TacticsCamera = null
var tactics_terrain : Terrain = null

var is_joystick = false

# --- camera --- #
func move_camera():
	var h = -Input.get_action_strength("camera_left")+Input.get_action_strength("camera_right")
	var v = Input.get_action_strength("camera_forward")-Input.get_action_strength("camera_backwards")
	tactics_camera.move_camera(h, v, is_joystick)

func camera_rotation():
	if Input.is_action_just_pressed("camera_rotate_left"): tactics_camera.y_rot -= 90
	if Input.is_action_just_pressed("camera_rotate_right"): tactics_camera.y_rot += 90
	
# Called when the node enters the scene tree for the first time.
func _ready():		
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#player.act(delta)
	move_camera()
	camera_rotation()
	pass
