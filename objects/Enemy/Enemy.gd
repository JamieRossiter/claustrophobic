# The parent that controls everything enemy-related
class_name Enemy extends CharacterBody3D

# General variables
@onready var original_position: Vector3 = position; ## The initial Enemy position, used for offsetting
var current_position_index: int; ## The Enemy's current index based on their position in the level
var current_state: Enums.EnemyState; ## The Enemy's current state (e.g. idle, aggro, roaming)
var is_moving: bool = false;

## Is the enemy moving forwards (e.g. pos idx is increasing 0,1,2,3) or backwards (e.g. pos idx is decreasing 3,2,1,0)
var direction: Enums.EnemyDirection = 0;

var target_index: int; ## The position index towards which the enemy should be moving

# Footstep speed
var min_footstep_speed: float = 0.3;
var max_footstep_speed: float = 1.0;
@onready var footstep_speed: float = max_footstep_speed;

# Footstep count
var footstep_count: int = 0;
var min_footstep_count: int = 2;
var max_footstep_count: int = 10;

# Move delay
var min_move_delay: float = 5.0;
var max_move_delay: float = 10.0;
var move_delay: float = max_move_delay;

# Timers
@onready var time_to_next_footstep: Timer = Timer.new(); ## Time before enemy takes a single footstep
@onready var time_to_next_move: Timer = Timer.new(); ## Time before enemy starts a series of footsteps
@onready var time_to_jumpscare: Timer = Timer.new(); ## Time before enemy teleports in front of player

# Signals
signal has_stepped;
signal jumpscare;
signal roaming_state_set;

func _ready() -> void:
	init_timers();
#	set_jumpscare();
#	set_aggro();
#	set_idle();
	set_roaming();
	
func init_timers() -> void:
	init_footstep_timer();
	init_move_timer();
	init_jumpscare_timer();

func init_footstep_timer() -> void:
	randomize_footstep_speed(); # Init footstep speed
	time_to_next_footstep.wait_time = footstep_speed;
	add_child(time_to_next_footstep);
	time_to_next_footstep.timeout.connect(emit_step);
	
func init_move_timer() -> void:
	randomize_move_delay(); # Init move delay
	time_to_next_move.wait_time = move_delay;
	add_child(time_to_next_move);
	time_to_next_move.timeout.connect(start_moving);

func init_jumpscare_timer() -> void:
	time_to_jumpscare.wait_time = 3;
	add_child(time_to_jumpscare);
	time_to_jumpscare.timeout.connect(perform_jumpscare);

## Emits the [code]has_stepped[/code] signal once an enemy takes a single footstep.
func emit_step() -> void:
	# If footsteps finished
	if(footstep_count < 1):
		stop_moving();
		randomize_footstep_count();
		return;
	has_stepped.emit();
	footstep_count -= 1;
	print("Footstep count ", footstep_count);

## Start a series of steps
func start_moving() -> void:
	is_moving = true;
	time_to_next_move.stop();
	time_to_next_footstep.start();
	randomize_footstep_count();
	print("Started moving");

## Stop moving, but trigger another series of steps shortly, after a delay
func stop_moving() -> void:
	is_moving = false;
	time_to_next_move.start();
	time_to_next_footstep.stop();
	print("Stopped moving");

## Stop moving and don't trigger another series of steps after a delay
func stop_moving_completely() -> void:
	is_moving = false;
	print("Stopped moving completely");

func perform_jumpscare() -> void:
	time_to_jumpscare.stop();
	jumpscare.emit();
	
func move_to_position(cell: Vector3i):
	position = Vector3(cell) + original_position;

# Randomizers
func randomize_footstep_speed() -> void:
	set_footstep_speed(randf_range(min_footstep_speed, max_footstep_speed));
	
func randomize_move_delay() -> void:
	set_move_delay(randf_range(min_move_delay, max_move_delay));

func randomize_footstep_count() -> void:
	set_footstep_count(randf_range(min_footstep_count, max_footstep_count));

# Setters
func set_footstep_speed(speed: float) -> void:
	footstep_speed = speed;

func set_move_delay(delay: float) -> void:
	move_delay = delay;

func set_footstep_count(count: int) -> void:
	footstep_count = count;

func set_current_state(state: Enums.EnemyState) -> void:
	current_state = state;
	
func set_target_index(index: int) -> void:
	target_index = index;

func set_aggro() -> void:
	set_current_state(Enums.EnemyState.AGGRO);
	start_moving();

func set_idle() -> void:
	set_current_state(Enums.EnemyState.IDLE);
	stop_moving_completely();

func set_roaming() -> void:
	set_current_state(Enums.EnemyState.ROAMING);
	start_moving();
	roaming_state_set.emit();

func set_jumpscare() -> void:
	set_current_state(Enums.EnemyState.JUMPSCARE);
	time_to_jumpscare.start();
	stop_moving_completely();
