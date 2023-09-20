extends Node3D
class_name  Terrain

var valid_grid_list = [ Vector2(1,0), Vector2(1,1), Vector2(1,2), Vector2(1,3), Vector2(2,3), Vector2(3,3), Vector2(2,3)   ]
var invalid_grid_list = [Vector2(0,0)]

var interact_grid_list = { Vector2(1,0): "(1,0)", Vector2(1,3):"(1,3)"}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
