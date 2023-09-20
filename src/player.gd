extends CharacterBody3D
class_name Player

enum State{
	IDLE,
	MOVE,
	JUMP
}

const SPEED = 5

var tactics_camera : TacticsCamera = null
var tactics_terrain : Terrain = null
var ui : Control = null

var is_joystick = false

var player_grid_positon: Vector2 = Vector2(0,0)
var target_grid_positon: Vector2

var player_state: int = State.IDLE

var pawn : Pawn = null

var valid_grid_list = null
var invalid_grid_list = null

var dir = Vector3(1,0,1);

func configure(my_camera : TacticsCamera , my_terrain: Terrain, my_ui: Control):
	tactics_camera = my_camera
	tactics_terrain = my_terrain
	ui = my_ui
	valid_grid_list = tactics_terrain.valid_grid_list
	invalid_grid_list = tactics_terrain.invalid_grid_list
	
# --- camera --- #
func move_camera():
	var h = -Input.get_action_strength("camera_left")+Input.get_action_strength("camera_right")
	var v = Input.get_action_strength("camera_forward")-Input.get_action_strength("camera_backwards")
	tactics_camera.move_camera(h, v, is_joystick)

func camera_rotation():
	if Input.is_action_just_pressed("camera_rotate_left"): tactics_camera.y_rot -= 90
	if Input.is_action_just_pressed("camera_rotate_right"): tactics_camera.y_rot += 90

# --- player --- #
func move_player(delta):
	if player_state == State.IDLE: 
		pawn.enter_idle_animation()
		var h = -Input.get_action_strength("player_left")+Input.get_action_strength("player_right")
		var v = -Input.get_action_strength("player_up")+Input.get_action_strength("player_down")
		if h != 0:
			target_grid_positon = Vector2(player_grid_positon.x + h , player_grid_positon.y)
			if check_can_move(target_grid_positon): 
				player_state = State.MOVE
				print("---start moving  current grid pos: " ,player_grid_positon ,"; target grid pos: " , target_grid_positon , "---")
		else :
			if v!= 0:
				target_grid_positon = Vector2(player_grid_positon.x, player_grid_positon.y +v)
				if check_can_move(target_grid_positon):
					player_state = State.MOVE
					print("---start moving  current grid pos: " ,player_grid_positon ,"; target grid pos: " , target_grid_positon , "---")
	
	move_to_target_grid()
	var vel = Vector3(target_grid_positon.x - player_grid_positon.x, 0 , target_grid_positon.y - player_grid_positon.y)
	#pawn.look_at_direction(vel)

func show_ui():
	if player_state == State.IDLE: 
		if Input.is_action_just_pressed("player_interact"):
			var interact_grid_pos = Vector2(player_grid_positon.x + dir.x, player_grid_positon.y+ dir.z)
			print("---interact with grid pos: " ,interact_grid_pos  , "---")
			if interact_grid_pos in tactics_terrain.interact_grid_list.keys():
				ui.show_ui(tactics_terrain.interact_grid_list.get(interact_grid_pos))

func check_can_move(target_grid):
	#if target_grid in valid_grid_list: return true
	if target_grid in invalid_grid_list: return false
	return true
	
func act(delta):
	move_camera()
	camera_rotation()
	show_ui()
	move_player(delta)
	
func move_to_target_grid():
	if player_state != State.MOVE: return
	#set_position(Vector3(grid_pos.x+0.5, , grid_pos.y+0.5))
	
	var vel = Vector3(target_grid_positon.x - player_grid_positon.x, 0 , target_grid_positon.y - player_grid_positon.y)
	dir = vel
	
	set_velocity(vel*SPEED)
	set_up_direction(Vector3.UP)
	move_and_slide()

	pawn.look_at_direction(vel)
	
	pawn.enter_walk_animation()
	
	var cur_pos :Vector2 = Vector2(position.x , position.z)
	if cur_pos.distance_to(get_target_pos()) >= 0.05: return
	
	### 到達目的grid
	player_grid_positon = target_grid_positon
	reset_to_grid(target_grid_positon)
	player_state = State.IDLE
	print("---end moving  current grid pos: ", player_grid_positon, "---")

func get_target_pos():
	return Vector2(target_grid_positon.x + 0.5, target_grid_positon.y + 0.5)
	
	
func reset_to_grid(grid_pos : Vector2):
	player_grid_positon = grid_pos
	position.x = grid_pos.x+0.5
	position.z = grid_pos.y+0.5


	
# Called when the node enters the scene tree for the first time.
func _ready():
	reset_to_grid(Vector2(0,0))
	pawn = $Pawn
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	act(delta)
	pass
