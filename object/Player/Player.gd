class_name Player extends CharacterBody3D

const JUMP_VELOCITY: float = 4.5;
const WALK_SPEED: float = 0.5;
const DASH_SPEED: float = 5.0;

var speed: float = WALK_SPEED;
var velocity_y: float = 0.0;
var dir: Enum.Direction = Enum.Direction.NONE; # Direction enum
var ammo: int = 1;
var is_aiming: bool = false; # If player is aiming gun

# Crawl
@onready var crawl_sound: AudioStreamPlayer = $Crawl;
@onready var crawl_timer: Timer = Timer.new();
var crawl_speed: float = 1.4;

func _ready() -> void:
	init_crawl_timer();

func _process(delta: float) -> void:	
	# Handle footstep sounds
	if(is_moving() and not is_aiming):
		if(not crawl_sound.playing):
			play_crawl_sound();
	else:
		stop_crawl_sound();
		
		

func _physics_process(delta: float) -> void:
		
#	if(Input.is_action_pressed("dash")):
#		speed = DASH_SPEED;
#	else:
#		speed = WALK_SPEED;
				
	var input_dir = Input.get_vector("move_west", "move_east", "move_north", "move_south");
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized();
	if direction:
		velocity.x = direction.x * speed;
		velocity.z = direction.z * speed;
	else:
		velocity.x = move_toward(velocity.x, 0, speed);
		velocity.z = move_toward(velocity.z, 0, speed);
	velocity.y = velocity_y;
	if(not is_aiming):
		move_and_slide();
	
func is_moving() -> bool:
	return velocity.x != 0 or velocity.y != 0 or velocity.z != 0

func init_crawl_timer() -> void:
	add_child(crawl_timer);
	crawl_timer.wait_time = crawl_speed;
	crawl_timer.timeout.connect(play_crawl_sound);

func play_crawl_sound() -> void:
	crawl_timer.start();
	crawl_sound.play();

func stop_crawl_sound() -> void:
	crawl_timer.stop();
