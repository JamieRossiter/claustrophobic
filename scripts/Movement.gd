class_name Movement extends Node

# Export variables
@export var MOVEMENT_SPEED: float = 10.0 / 10;
@export var character: CharacterBody3D = null;
@export var camera: Camera3D = null;

func _ready() -> void:
	Signals.player_move.connect(_handle_move);

func _physics_process(delta: float) -> void:
	# Handle camera bobble
	if(self.is_moving()):
		camera.start_bobble();
	else:
		camera.end_bobble();

# BUG: The player randomly speeds up at certain times or points in the map
func _handle_move() -> void:
	
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

# Is the player moving based on movement inputs and (lack of) aim input
func is_moving() -> bool:
	return (
		Input.get_vector("move_west", "move_east", "move_north", "move_south") != Vector2.ZERO
		and not
		Input.is_action_pressed("aim")
	);
