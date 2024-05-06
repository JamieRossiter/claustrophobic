class_name Movement extends Node

# Export variables
@export var MOVEMENT_SPEED: float = 1.5;
@export var character: CharacterBody3D = null;
@export var camera: Camera3D = null;

func _physics_process(delta: float) -> void:
	# Movement
	if(!Input.is_action_pressed("aim")):
		self._handle_movement(delta);
	
	# Handle camera bobble
	if(self.is_moving()):
		camera.start_bobble();
	else:
		camera.end_bobble();
		
func _input(event: InputEvent) -> void:
	# Rotation
	if(event is InputEventMouseMotion):
		character.rotation.y = character.rotation.y - (event.relative.x / 1000) * Globals.CAMERA_LOOK_SENSITIVITY.y;
		camera.rotation.x = clamp(camera.rotation.x - (event.relative.y / 1000) * Globals.CAMERA_LOOK_SENSITIVITY.x, -1.5, 1.5);

# BUG: Player moves faster than normal at certain points in the map (suspect this has something to do with framerate)
func _handle_movement(delta: float) -> void:
	var input: Vector2 = Input.get_vector("move_north", "move_south", "move_east", "move_west");
	var speed: float = MOVEMENT_SPEED;
	# Make backwards movment slower
	if Input.is_action_pressed("move_south"):
		speed = speed / 2;
	var movement_dir = character.transform.basis * Vector3(input.x, 0, input.y);
	character.velocity.x = movement_dir.x * speed;
	character.velocity.z = movement_dir.z * speed;
	character.move_and_slide();

# Is the player moving based on movement inputs and (lack of) aim input
func is_moving() -> bool:
	return (
		Input.get_vector("move_west", "move_east", "move_north", "move_south") != Vector2.ZERO
		and not
		Input.is_action_pressed("aim")
	);
