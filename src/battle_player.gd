extends BattleSprite
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
var pawn : Pawn = null
var cmd_panel : Node = null
var act_bar : Node = null
var select_tile = null

var player_grid: Vector2 = Vector2.ZERO
var target_grid: Vector2 = Vector2.ZERO

var act_state: int = ActState.IDLE
var player_state: int = PlayerState.IDLE

var dir = null;

var act_bar_position = 0

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
@export var player_id : String = ""
@export var act_speed : float = 2.0
@export var max_hp : int = 100
@export var max_mp : int = 100
@export var max_sp : float = 50
@export var cur_hp : int = 100
@export var cur_mp : int = 100
@export var cur_sp : float = 50
@export var sp_update_speed : float = 1.0
@export var init_grid : Vector2 = Vector2(0,0)

func configure(id : String, act_s : float, h : int, m: int, s : int):
	assert(player_id != "")
	player_id = id
	act_speed = act_s
	max_hp = h
	cur_hp = max_hp
	max_mp = m
	cur_mp = max_mp
	max_sp = s
	cur_sp = max_sp
 
func reset_to_grid(grid : Vector2):
	player_grid = grid
	position.x = grid.x+0.5
	position.z = grid.y+0.5

func enter_running():
	print(player_id, ": battle running, current hp:", cur_hp, " current mp:", cur_mp)

func enter_stop():
	print(player_id, ": battle stop ")

func pre_act(delta):
	#if action.keys()[0] == "move":
	if player_action == null: return
		#target_grid = action.get("move").get("position")
	act_bar_position = act_bar_position + (delta * act_speed)
	act_bar.get_node("ActPosition").text = str(int(act_bar_position/player_action.pre_range*100)) + "/100"
	if act_bar_position >= player_action.pre_range:
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
		act_bar_position = act_bar_position + (delta * act_speed)
		act_bar.get_node("ActPosition").text = str(int(act_bar_position/5*100)) + "/100"
		if act_bar_position >= 5:
			transit_act_state(ActState.IDLE)
		return

	act_bar_position = act_bar_position + (delta * act_speed)
	act_bar.get_node("ActPosition").text = str(int(act_bar_position/player_action.post_range*100)) + "/100"
	if act_bar_position >= player_action.post_range:
		transit_act_state(ActState.IDLE)

		
func cast_act_move():
	player_state = PlayerState.MOVE
	if !check_dst_available(target_grid):
		print(player_id ,": cast move faild because a player occuped")
		target_grid = player_grid
	if !check_grid_available(target_grid):
		print(player_id ,": cast move faild because not a valid grid pos")
		target_grid = player_grid
	var is_reach_dst = move_to_target_grid()
	if is_reach_dst:
		player_state = PlayerState.IDLE
		transit_act_state(ActState.COOLDOWN)
		
func cast_act_attack(delta):
	act_bar_position = act_bar_position + (delta * act_speed)
	if act_bar_position >= 10:
		transit_act_state(ActState.COOLDOWN)

func check_can_attack(action : Attack):
	var target = battle.get_player_from_grid_map(action.attack_position)
	if target == null : 
		print(player_id ,": no attack target")
		return false
	var distance_square = player_grid.distance_squared_to(target.player_grid)
	if distance_square > (action.attack_range * action.attack_range) * 2: 
		print(player_id ,": attack target out of range")
		return false
	action.attack_target = target
	print(player_id ,": attack target:", target.player_id)
	return true

func check_still_can_attack(action : Attack):
	var target_player = action.attack_target
	print(target_player.player_grid)
	var distance_square = player_grid.distance_squared_to(target_player.player_grid)
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
	var x = player_grid.x
	var y = player_grid.y
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
	#		"position" : (player_grid + v)
	#	}
	#}
	player_action = Move.new()
	player_action.target_position = player_grid + v
	
func check_action():
	if player_action == null : return false
	if player_action.act_name == Move.s_act_name:
		if cur_sp < Move.s_act_sp:
			player_action = null 
			return false
		else : 
			cur_sp = (cur_sp - Move.s_act_sp) 
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
	print(player_id ,": error state transit occuried")	

func idle_state_pre_act():
	act_bar_position = 0
	player_action = null
	act_bar.get_node("State").text = "IDLE"
	act_bar.get_node("ActPosition").text =  "0/100"
	cmd_panel.get_node("Level1/MainPanel").visible = true
	print(player_id ,": enter idle state" )
	
func idle_state_post_act():
	cmd_panel.clear_all_level()
	pass

func precast_state_pre_act():
	act_bar_position = 0
	act_bar.get_node("State").text = "PRECAST"
	if player_action.act_name == Move.s_act_name:
		target_grid = player_action.target_position
	print(player_id ,": enter precast state" )

func precast_state_post_act():
	pass
	
func cast_state_pre_act():
	act_bar_position = 0
	battle.change_state(battle.TacticsState.STOP)
	act_bar.get_node("State").text = "CAST"
	print(player_id ,": enter cast state")
	if player_action.act_name == Move.s_act_name:
		pass #todo 考虑把移动判断移动到这里
	if player_action.act_name == Attack.s_act_name:
		if check_still_can_attack(player_action):
			pawn.enter_attack_animation()
			do_attack_damage(player_action)
		else:
			print(player_id ,": attack out of range" )
			transit_act_state(ActState.COOLDOWN)
	
func cast_state_post_act():
	pass

func cooldown_state_pre_act():
	act_bar_position = 0
	battle.change_state(battle.TacticsState.RUNNING)
	act_bar.get_node("State").text = "COOLDOWN"
	pawn.enter_idle_animation()
	print(player_id ,": enter cooldown state" )
	
func cooldown_state_post_act():
	pass
	
func move_to_target_grid() -> bool:
	if player_state != PlayerState.MOVE: return false
	#set_position(Vector3(grid_pos.x+0.5, , grid_pos.y+0.5))
	
	var vel = Vector3(target_grid.x - player_grid.x, 0 , target_grid.y - player_grid.y)
	dir = vel
	
	set_velocity(vel*SPEED)
	set_up_direction(Vector3.UP)
	move_and_slide()

	pawn.look_at_direction(vel)
	pawn.enter_walk_animation()
	
	var cur_pos :Vector2 = Vector2(position.x , position.z)
	if cur_pos.distance_to(get_target_pos()) >= 0.05: return false
	
	### 到達目的grid
	battle.set_player_grid_map(player_grid,target_grid,self)
	player_grid = target_grid
	reset_to_grid(target_grid)
	pawn.enter_idle_animation()
	print(player_id ,": end moving  current grid pos: ", player_grid)
	return true

func get_target_pos():
	return Vector2(target_grid.x + 0.5, target_grid.y + 0.5)

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

func do_attack_damage(attack : Attack):
	var h = attack.attack_target.cur_hp - attack.attack_damage
	if h < 0:
		attack.attack_target.cur_hp = 0
	else:
		attack.attack_target.cur_hp = h
	print(player_id, ": attack ", attack.attack_target.player_id, " damage: ", attack.attack_damage)

# Called when the node enters the scene tree for the first time.
func _ready():
	assert(player_id != "")
	reset_to_grid(init_grid)
	pawn = $Pawn
	battle = find_parent("Battle")
	cmd_panel = get_node("CmdPanel")
	act_bar = get_node("ActBar")
	select_tile = get_node("SelectTile")
	select_tile.visible = false
	act_bar_position = 0
	transit_act_state(ActState.COOLDOWN)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	tactics_act(delta)
	update_act_bar()
	update_cmd_panel()
	pass
