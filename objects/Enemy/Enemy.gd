class_name Enemy extends CharacterBody3D
#TODO: Add ability to switch between roaming, aggro and teleport states
#TODO: Add teleport functionality. Monster can teleport a few indexes behind/in front of player
#TODO: If monster near end of max index and target is a low number, don't automatically move backwards, but continue moving forwards and reset index after reaching max index.

# General variables
var original_position: Vector3;
var current_position_index: int;
var is_aggro: bool = false;
var is_moving: bool = false;
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
@onready var time_to_next_footstep: Timer = Timer.new();
@onready var time_to_next_move: Timer = Timer.new();
# Signals
signal has_stepped;

func _ready() -> void:
	init_footstep_timer();
	init_move_timer();
	randomize_footstep_count();
	original_position = position;

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
	time_to_next_move.start();

func emit_step() -> void:
	# If footsteps finished
	if(footstep_count < 1):
		stop_moving();
		randomize_footstep_count();
		return;
	has_stepped.emit();
	footstep_count -= 1;
	print("Footstep count ", footstep_count);
	
func start_moving() -> void:
	is_moving = true;
	time_to_next_move.stop();
	time_to_next_footstep.start();
	print("Started moving");

func stop_moving() -> void:
	is_moving = false;
	time_to_next_move.start();
	time_to_next_footstep.stop();
	print("Stopped moving");
	
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
