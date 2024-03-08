"""
Player.gd
Contains the Player class, which houses the master logic for everything player-related
Author: Jamie Rossiter
"""
class_name Player extends CharacterBody3D

# Constants
const WALK_SPEED: float = 50 * 0.01;
const ACCELERATION: float = 100.0;

# General variables
var speed: float = WALK_SPEED;
var velocity_y: float = 0.0;
var ammo: int = 3;

# Onready variables
@onready var camera: PlayerCamera = $PlayerCamera;
@onready var animation: PlayerAnimation = $PlayerCamera/PlayerAnimation;

# Signals
signal shoot;
signal shoot_dry;
signal reload;

func _process(delta: float) -> void:
	handle_shoot();
	handle_reload();

func _physics_process(delta: float) -> void:
	handle_movement(delta);


func handle_movement(delta: float) -> void:
	# Inputs for determining direction	
	var input_dir = Input.get_vector("move_west", "move_east", "move_north", "move_south");
	
	# Make backwards movment slower
	if Input.is_action_pressed("move_south"):
		speed = WALK_SPEED / 3;
	else:
		speed = WALK_SPEED;
	
	# Direction	
	var direction = (camera.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized();
	if direction:
		velocity.x = direction.x * (speed * (ACCELERATION * delta));
		velocity.z = direction.z * (speed * (ACCELERATION * delta));
	else:
		velocity.x = move_toward(velocity.x, 0, speed * (ACCELERATION * delta));
		velocity.z = move_toward(velocity.z, 0, speed * (ACCELERATION * delta));
	velocity.y = velocity_y;
	
	# Move
	if(not self.is_aiming()):
		move_and_slide();

func handle_shoot():
	if(
		Input.is_action_pressed("aim") and 
		Input.is_action_just_pressed("shoot") and 
		not animation.is_animation_reloading and
		not animation.is_animation_shooting
	):
		if(ammo <= 0):
			self.emit_signal("shoot_dry");
			return;
		self.emit_signal("shoot", ammo);
		ammo = ammo -1;

func handle_reload():
	if(
		Input.is_action_just_pressed("reload") and
		Input.is_action_pressed("aim") and 
		ammo <= 0 and
		not animation.is_animation_reloading and 
		not animation.is_animation_shooting
	):
		self.emit_signal("reload");
		ammo = 3;

func is_moving() -> bool:
	return velocity.x != 0 or velocity.y != 0 or velocity.z != 0

func is_aiming() -> bool:
	return Input.is_action_pressed("aim");
