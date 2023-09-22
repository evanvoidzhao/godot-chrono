extends CharacterBody3D
class_name BattlePlayer

enum ActState{
	IDLE,
	COOLDOWN,
	PRECAST,
	CAST
}

enum PlayerState{
	IDLE,
	MOVE
}

const SPEED = 5

var battle : Battle = null
var ui : Control = null
var pawn : Pawn = null
var cmd_panel : Node = null
var act_bar : Node = null
var select_tile = null

var player_grid_positon: Vector2 = Vector2.ZERO
var target_grid_positon: Vector2 = Vector2.ZERO

var act_state: int = ActState.IDLE
var player_state: int = PlayerState.IDLE

var dir = null;

var player_id = null
var act_speed = null
var act_position = null

#var action = null
var player_action : Action = null

#var act_op = {
#	"move" : {
#		"pre_range" : 1,
#		"post_range": 5
#	},
#	"attack" : {
#		"pre_range" : 3,
#		"post_range": 8,
#		"attack_range": 5,
#		"damage" : 10
#	}
#} 

var max_hp  = 0
var max_mp  = 0
var max_sp  = 0
var cur_hp  = 0
var cur_mp  = 0
var cur_sp  = 0

var sp_update_speed = 1

func configure(id : String, act_s : float, h : int, m: int, s : int):
	player_id = id
	act_speed = act_s
	max_hp = h
	cur_hp = max_hp
	max_mp = m
	cur_mp = max_mp
	max_sp = s
	cur_sp = max_sp

func reset_to_grid(grid_pos : Vector2):
	player_grid_positon = grid_pos
	position.x = grid_pos.x+0.5
	position.z = grid_pos.y+0.5

func enter_running():
	print(player_id, ": battle running ")

func enter_stop():
	print(player_id, ": battle stop ")
	
func pre_act(delta):
	#if action.keys()[0] == "move":
	if player_action == null: return
		#target_grid_positon = action.get("move").get("position")
	act_position = act_position + (delta * act_speed)
	act_bar.get_node("ActPosition").text = str(int(act_position/player_action.pre_range*100)) + "/100"
	if act_position >= player_action.pre_range:
		transit_act_state(ActState.CAST)
	return

func cast(delta):	
	match player_action.act_name :
		Move.s_act_name:
			cast_act_move()	
		Attack.s_act_name:
			cast_act_attack(delta)	
	
func cooldown(delta):
	if player_action == null:
		act_position = act_position + (delta * act_speed)
		act_bar.get_node("ActPosition").text = str(int(act_position/5*100)) + "/100"
		if act_position >= 5:
			transit_act_state(ActState.IDLE)
		return

	act_position = act_position + (delta * act_speed)
	act_bar.get_node("ActPosition").text = str(int(act_position/player_action.post_range*100)) + "/100"
	if act_position >= player_action.post_range:
		transit_act_state(ActState.IDLE)

		
func cast_act_move():
	player_state = PlayerState.MOVE
	if !check_dst_available(target_grid_positon):
		print(player_id ,": cast move faild because a player occuped")
		target_grid_positon = player_grid_positon
	if !check_grid_available(target_grid_positon):
		print(player_id ,": cast move faild because not a valid grid pos")
		target_grid_positon = player_grid_positon
	var is_reach_dst = move_to_target_grid()
	if is_reach_dst:
		player_state = PlayerState.IDLE
		transit_act_state(ActState.COOLDOWN)
		
func cast_act_attack(delta):
	act_position = act_position + (delta * act_speed)
	if act_position >= 10:
		transit_act_state(ActState.COOLDOWN)

func check_can_attack(action : Attack):
	var target = battle.get_player_from_grid_map(action.attack_position)
	if target == null : 
		print(player_id ," no attack target")
		return false
	action.attack_target = target
	print(player_id ," attack target:", target.player_id)
	return true

func check_still_can_attack(action : Attack):
	var target_player = action.attack_target
	print(target_player.player_grid_positon)
	var distance_square = player_grid_positon.distance_squared_to(target_player.player_grid_positon)
	if distance_square > (action.attack_range * action.attack_range) * 2: 
		return false
	else:
		return true
	

func update_sp(delta):
	if cur_sp < max_sp:
		cur_sp = cur_sp + (delta * sp_update_speed)
	else:
		cur_sp = max_sp
	act_bar.get_node("SP").text = str(int(cur_sp)) + "/" + str(max_sp)

func check_dst_available(v):
	if battle.get_player_from_grid_map(v) == null : return true
	else: return false

func check_grid_available(v):
	return battle.check_grid_available(v)
	
func random_move_target():
	var x = player_grid_positon.x
	var y = player_grid_positon.y
	var xory = randi_range(0, 1)
	var addorminus = randi_range(0, 1)
	if xory :
		if addorminus:
			x = x + 1
		else :
			x = x - 1
	else :
		if addorminus:
			y = y + 1
		else :
			y = y - 1
	#action = {
	#	"move" : {
	#		"position" : Vector2(x,y)
	#	}
	#}
	player_action = Move.new()
	player_action.target_position = Vector2(x,y)

func move_target(v : Vector2):
	#action = {
	#	"move" : {
	#		"position" : (player_grid_positon + v)
	#	}
	#}
	player_action = Move.new()
	player_action.target_position = player_grid_positon + v
	
func check_action():
	if player_action == null : return false
	if player_action.act_name == Move.s_act_name:
		if cur_sp < 50:
			player_action = null 
			return false
		else : 
			cur_sp = (cur_sp - 50) 
			return true
	if player_action.act_name == Attack.s_act_name:
		if check_can_attack(player_action):
			return true
		else:
			player_action = null 
			return false


func check_idle_input(delta):
	if Input.is_action_just_pressed("player_interact"):
		player_action = Attack.new()
		player_action.attack_position.x = select_tile.global_position.x-0.5
		player_action.attack_position.y = select_tile.global_position.z-0.5
		enable_select_tile(false)
		return
	if Input.is_action_just_pressed("player_left"):
		select_tile.position.x -= 1
		return
	if Input.is_action_just_pressed("player_right"):
		select_tile.position.x += 1
		return
	if Input.is_action_just_pressed("player_up"):
		select_tile.position.z -= 1
		return
	if Input.is_action_just_pressed("player_down"):
		select_tile.position.z += 1
		return
	
func tactics_act(delta):
	if battle.tactics_state == battle.TacticsState.RUNNING :
		if act_state == ActState.COOLDOWN:
			cooldown(delta)
		if act_state == ActState.IDLE:
			check_idle_input(delta)
			if check_action():
				transit_act_state(ActState.PRECAST)
		if act_state == ActState.PRECAST:
			pre_act(delta)
		##update sp
		update_sp(delta)
	if battle.tactics_state == battle.TacticsState.STOP :
		if act_state == ActState.CAST:
			cast(delta)

func transit_act_state(state):
	if act_state == ActState.IDLE:
		idle_state_post_act()
		if state == ActState.PRECAST:
			act_state = state
			precast_state_pre_act()
			return
		if state == ActState.COOLDOWN:
			act_state = state
			cooldown_state_pre_act()
			return
	if act_state == ActState.PRECAST:
		precast_state_post_act()
		if state == ActState.CAST:
			act_state = state
			cast_state_pre_act()
			return
	if act_state == ActState.CAST:
		cast_state_post_act()
		if state == ActState.COOLDOWN:
			act_state = state
			cooldown_state_pre_act()
			return
	if act_state == ActState.COOLDOWN:
		cooldown_state_post_act()
		if state == ActState.IDLE:
			act_state = state
			idle_state_pre_act()
			return
	print(player_id ,"error state transit occuried")	

func idle_state_pre_act():
	act_position = 0
	player_action = null
	act_bar.get_node("State").text = "IDLE"
	act_bar.get_node("ActPosition").text =  "0/100"
	cmd_panel.get_node("Level1/MainPanel").visible = true
	print(player_id ,": enter idle state" )
	
func idle_state_post_act():
	cmd_panel.clear_all_level()
	pass

func precast_state_pre_act():
	act_position = 0
	act_bar.get_node("State").text = "PRECAST"
	if player_action.act_name == Move.s_act_name:
		target_grid_positon = player_action.target_position
	print(player_id ,": enter precast state" )

func precast_state_post_act():
	pass
	
func cast_state_pre_act():
	act_position = 0
	battle.change_state(battle.TacticsState.STOP)
	act_bar.get_node("State").text = "CAST"
	print(player_id ,": enter cast state")
	if player_action.act_name == Move.s_act_name:
		pass #todo 考虑把移动判断移动到这里
	if player_action.act_name == Attack.s_act_name:
		if !check_still_can_attack(player_action):
			print(player_id ,": attack out of range" )
			transit_act_state(ActState.COOLDOWN)
	
func cast_state_post_act():
	pass

func cooldown_state_pre_act():
	act_position = 0
	battle.change_state(battle.TacticsState.RUNNING)
	act_bar.get_node("State").text = "COOLDOWN"
	print(player_id ,": enter cooldown state" )
	
func cooldown_state_post_act():
	pass
	
func move_to_target_grid() -> bool:
	if player_state != PlayerState.MOVE: return false
	#set_position(Vector3(grid_pos.x+0.5, , grid_pos.y+0.5))
	
	var vel = Vector3(target_grid_positon.x - player_grid_positon.x, 0 , target_grid_positon.y - player_grid_positon.y)
	dir = vel
	
	set_velocity(vel*SPEED)
	set_up_direction(Vector3.UP)
	move_and_slide()

	pawn.look_at_direction(vel)
	pawn.enter_walk_animation()
	
	var cur_pos :Vector2 = Vector2(position.x , position.z)
	if cur_pos.distance_to(get_target_pos()) >= 0.05: return false
	
	### 到達目的grid
	battle.set_player_grid_map(player_grid_positon,target_grid_positon,self)
	player_grid_positon = target_grid_positon
	reset_to_grid(target_grid_positon)
	pawn.enter_idle_animation()
	print(player_id ,": end moving  current grid pos: ", player_grid_positon)
	return true

func get_target_pos():
	return Vector2(target_grid_positon.x + 0.5, target_grid_positon.y + 0.5)

func update_act_bar():
	var camera = get_viewport().get_camera_3d()
	var pos = camera.unproject_position(global_position)
	pos.y -= 180
	pos.x -= 20
	act_bar.set_position(pos)

func update_cmd_panel():
	var camera = get_viewport().get_camera_3d()
	var pos = camera.unproject_position(global_position)
	pos.y -= 180
	pos.x -= 80
	cmd_panel.set_position(pos)
	
func enable_select_tile(b : bool):
	select_tile.position.x = 0
	select_tile.position.z = 0
	select_tile.visible = b
	
# Called when the node enters the scene tree for the first time.
func _ready():
	reset_to_grid(Vector2(0,0))
	pawn = $Pawn
	battle = get_parent()
	cmd_panel = get_node("CmdPanel")
	act_bar = get_node("ActBar")
	select_tile = get_node("SelectTile")
	select_tile.visible = false
	act_position = 0
	transit_act_state(ActState.COOLDOWN)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	tactics_act(delta)
	update_act_bar()
	update_cmd_panel()
	pass
