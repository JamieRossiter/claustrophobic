# Movement.gd
# Author: Jamie Rossiter
# Last Updated: 20/04/24
# Handles all user-related movement and collision
class_name Movement extends Node

# Export variables
@export var MOVEMENT_SPEED: float = 10.0;
@export var character: CharacterBody3D = null;
@export var camera: Camera3D = null;

func _ready() -> void:
	Signals.move.connect(_handle_move);

func _handle_move() -> void:
	
	print("Moving");
	
	# Determine direction based on input
	var input_dir = Input.get_vector("move_west", "move_east", "move_north", "move_south");
	var speed = MOVEMENT_SPEED;

	# Direction	
	var dir = (camera.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized();
	if(dir):
		character.velocity.x = dir.x * (speed * (100.0 * get_physics_process_delta_time()));
		character.velocity.z = dir.z * (speed * (100.0 * get_physics_process_delta_time()));
	else:
		character.velocity.x = move_toward(character.velocity.x, 0, speed * (100.0 * get_physics_process_delta_time()));
		character.velocity.z = move_toward(character.velocity.z, 0, speed * (100.0 * get_physics_process_delta_time()));

	# Move
	character.move_and_slide();
