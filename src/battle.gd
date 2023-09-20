extends Node3D
class_name Battle

#var player1 : BattlePlayer = null
#var player2 : BattlePlayer = null
var tactics_camera : TacticsCamera = null
var tactics_terrain : Terrain = null

var is_joystick = false

var player_grid_map:Dictionary = {}
var invalid_grid_list = [Vector2.ZERO]

enum TacticsState{
	CONF,
	RUNNING,
	STOP,
	END
}

var tactics_state = TacticsState.CONF

# --- camera --- #
func move_camera():
	var h = -Input.get_action_strength("camera_left")+Input.get_action_strength("camera_right")
	var v = Input.get_action_strength("camera_forward")-Input.get_action_strength("camera_backwards")
	tactics_camera.move_camera(h, v, is_joystick)

func camera_rotation():
	if Input.is_action_just_pressed("camera_rotate_left"): tactics_camera.y_rot -= 90
	if Input.is_action_just_pressed("camera_rotate_right"): tactics_camera.y_rot += 90

func change_state(s : int):
	if tactics_state == TacticsState.CONF:
		if s == TacticsState.RUNNING:
			tactics_state = TacticsState.RUNNING
			enter_running()
	if tactics_state == TacticsState.RUNNING:
		if s == TacticsState.STOP:
			tactics_state = TacticsState.STOP
			enter_stop()
	if tactics_state == TacticsState.STOP:
		if s == TacticsState.RUNNING:
			tactics_state = TacticsState.RUNNING
			enter_running()
					
func enter_running():
	for grid_pos in player_grid_map:
		var player = player_grid_map[grid_pos]
		player.enter_running()
	
func enter_stop():
	for grid_pos in player_grid_map:
		var player = player_grid_map[grid_pos]
		player.enter_stop()

func vector2_to_str(v:Vector2):
	return str(v.x) + "," + str(v.y)

func str_to_vector2(s:String):
	var a = s.split_floats(",")
	return Vector2(a[0], a[1])
	
func set_player_grid_map(old_pos:Vector2, new_pos:Vector2, player:BattlePlayer):
	player_grid_map.erase(vector2_to_str(old_pos))
	player_grid_map[vector2_to_str(new_pos)] = player
	
func get_player_from_grid_map(v:Vector2):
	return player_grid_map.get(vector2_to_str(v))
	
func check_grid_available(v:Vector2):
	return !(v in invalid_grid_list)
	
# Called when the node enters the scene tree for the first time.
func _ready():	
	#player1 = get_node("Player")
	#player2 = get_node("Player2")
	tactics_camera = get_node("TacticsCamera")
	tactics_terrain = get_node("Terrain")
	
	var scene = preload("res://assets/battle_player.tscn")
	for i in [0,1,2]:
		var p : BattlePlayer = scene.instantiate()
		
		self.add_child(p)
		p.configure("player"+str(i), randf_range(0.5, 1.5),100,100,50)
		var grid_player = vector2_to_str(Vector2(0,1+i))
		player_grid_map[grid_player] = p
		
	#player1.configure("player1", 0.7)
	#player2.configure("player2", 1)
	#player2.reset_to_grid(Vector2(0,1))
	
	var grid_player1 = vector2_to_str(Vector2(0,1))
	var grid_player2 = vector2_to_str(Vector2(0,2))
	
	#player_grid_map[grid_player1] = player1
	#player_grid_map[grid_player2] = player2 
	
	for grid_pos in player_grid_map:
		var player = player_grid_map[grid_pos]
		player.reset_to_grid(str_to_vector2(grid_pos))
	
	change_state(TacticsState.RUNNING)
	
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#player.act(delta)
	move_camera()
	camera_rotation()
	pass
