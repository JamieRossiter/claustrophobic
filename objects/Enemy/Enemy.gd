class_name Enemy extends CharacterBody3D
#TODO: If monster near end of max index and target is a low number, don't automatically move backwards, but continue moving forwards and reset index after reaching max index.
#TODO: Clean up code files

# General variables
@onready var original_position: Vector3 = position;
var current_position_index: int;
var current_state: Enums.EnemyState;
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
@onready var time_to_jumpscare: Timer = Timer.new();
# Signals
signal has_stepped;
signal jumpscare;

func _ready() -> void:
	init_timers();
	set_jumpscare();
	
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
	randomize_footstep_count();
	print("Started moving");

func stop_moving() -> void:
	is_moving = false;
	time_to_next_move.start();
	time_to_next_footstep.stop();
	print("Stopped moving");

func stop_moving_completely() -> void:
	is_moving = false;
	print("Stopped moving completely");

func perform_jumpscare() -> void:
	time_to_jumpscare.stop();
	jumpscare.emit();
	
func move_to_position(cell: Vector3i):
	position = Vector3(cell) + original_position;

func set_aggro() -> void:
	set_current_state(Enums.EnemyState.AGGRO);
	start_moving();

func set_idle() -> void:
	set_current_state(Enums.EnemyState.IDLE);
	stop_moving_completely();

func set_roaming() -> void:
	set_current_state(Enums.EnemyState.ROAMING);
	start_moving();

func set_jumpscare() -> void:
	set_current_state(Enums.EnemyState.JUMPSCARE);
	time_to_jumpscare.start();
	stop_moving_completely();

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
