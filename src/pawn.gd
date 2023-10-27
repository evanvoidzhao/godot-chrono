extends Node3D
class_name Pawn


enum State{
	IDLE,
	MOVE,
	JUMP,
	ATTACK
}

var animation_state = State.IDLE
const ANIMATION_FRAMES = 4
var curr_frame : int = 0
@onready var animation_player = get_node("Character/AnimationPlayer")

@export var player_type : String = ""

func rotate_pawn_sprite():
	var camera_forward = -get_viewport().get_camera_3d().global_transform.basis.z
	var dot = global_transform.basis.z.dot(camera_forward)
	$Character.flip_h = global_transform.basis.x.dot(camera_forward) > 0
	#if dot < -0.306: $Character.frame = curr_frame
	#elif dot > 0.306: $Character.frame = curr_frame + 1 * ANIMATION_FRAMES	
	if dot < -0.306: 
		if animation_state == State.IDLE :
			$Character.frame = curr_frame
			animation_player.play("idle_down_" + player_type)
		if animation_state == State.MOVE :
			animation_player.play("walk_down_" + player_type)
		if animation_state == State.ATTACK :
			animation_player.play("attack_down_" + player_type)
	elif dot > 0.306: 
		if animation_state == State.IDLE :
			animation_player.play("idle_up_" + player_type)
		if animation_state == State.MOVE :
			animation_player.play("walk_up_" + player_type)
		if animation_state == State.ATTACK :
			animation_player.play("attack_down_" + player_type)

func look_at_direction(dir):
	var fixed_dir = dir*(Vector3(1,0,0) if abs(dir.x) > abs(dir.z) else Vector3(0,0,1))
	var angle = Vector3.FORWARD.signed_angle_to(fixed_dir.normalized(), Vector3.UP)+PI
	set_rotation(Vector3.UP*angle)

func enter_idle_animation():
	animation_state = State.IDLE

func enter_walk_animation():
	animation_state = State.MOVE
	
func enter_attack_animation():
	animation_state = State.ATTACK
	
func set_character_texture(type):
	if type == "player":
		$Character.texture = load("res://assets/sprites/characters/chr_ro_FeiKanabian.png")  
	if type == "enemy":
		$Character.texture = load("res://assets/sprites/characters/chr_ro_loki.png")  

		
# Called when the node enters the scene tree for the first time.
func _ready():
	set_character_texture(player_type)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotate_pawn_sprite()
	pass
