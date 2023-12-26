class_name Player extends CharacterBody3D

@export var god_mode_active: bool = false;

const JUMP_VELOCITY: float = 4.5;
const WALK_SPEED: float = 0.5;
const DASH_SPEED: float = 1.0;

@onready var speed: float = WALK_SPEED;
#var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity");
var velocity_y: float = 0.0;

var direction: String = "";
var ammo: int = 1;

func _physics_process(delta: float):
		
	if(Input.is_action_pressed("dash")):
		speed = DASH_SPEED;
	else:
		speed = WALK_SPEED;
	
#	if(is_on_floor()):
#		velocity_y = 0;
#	else:
#		if(not god_mode_active):
#			velocity_y -= gravity * delta;
			
	var input_dir = Input.get_vector("move_west", "move_east", "move_north", "move_south");
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized();
	if direction:
		velocity.x = direction.x * speed;
		velocity.z = direction.z * speed;
	else:
		velocity.x = move_toward(velocity.x, 0, speed);
		velocity.z = move_toward(velocity.z, 0, speed);
	velocity.y = velocity_y;
	move_and_slide();
	
func is_moving() -> bool:
	return velocity.x != 0 or velocity.y != 0 or velocity.z != 0
