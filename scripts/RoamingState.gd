# RoamingState.gd
extends EnemyState

# Exports
@export var enemy: Enemy;
@export var level: Level;

# Step count
const MIN_STEP_COUNT: int = 5;
const MAX_STEP_COUNT: int = 10;
var current_step_count: int = 0;

# Step interval
const SHORTEST_STEP_INTERVAL: float = 1.0;
const LONGEST_STEP_INTERVAL: float = 2.0;
var current_step_interval: float;
var step_interval_timer: Timer = Timer.new();

# Roam interval
const SHORTEST_ROAM_INTERVAL: float = 5.0;
const LONGEST_ROAM_INTERVAL: float = 10.0;
var current_roam_interval: float;
var roam_interval_timer: Timer = Timer.new();

func _ready() -> void:
	_init_timers();

func start() -> void:
	super();
	_reset_parameters();
	_randomize_parameters();
	_start_timers();
	# Prevent roam interval timer from being set off before steps completed
	roam_interval_timer.stop(); 

func stop() -> void:
	super();
	_reset_parameters();
	_stop_timers();

func _randomize_parameters() -> void:
	current_step_count = _randomize_step_count();
	current_step_interval = _randomize_step_interval();
	current_roam_interval = _randomize_roam_interval();
	enemy.current_target_index = level.get_random_index();

func _reset_parameters() -> void:
	current_step_count = 0;
	current_step_interval = LONGEST_STEP_INTERVAL;
	current_roam_interval = LONGEST_ROAM_INTERVAL;
	enemy.current_target_index = -1;

func _stop_roaming_temporarily() -> void:
	step_interval_timer.stop();
	self._start_timer(roam_interval_timer, _randomize_roam_interval());

func _init_timers() -> void:
	self._init_timer(step_interval_timer, _step);
	self._init_timer(roam_interval_timer, start);

func _start_timers() -> void:
	self._start_timer(step_interval_timer, _randomize_step_interval());

func _stop_timers() -> void:
	step_interval_timer.stop();
	roam_interval_timer.stop();

func _step() -> void:
	var at_target_index: bool = enemy.at_target_index();
	var random_index: int = level.get_random_index();
	
	if(at_target_index):
		enemy.current_target_index = random_index;
		
	if(current_step_count == 0):
		_stop_roaming_temporarily(); 
		return;
	
	self._step_toward_target_index(enemy, level);
	current_step_count -= 1;
	print("Current Roam Step Count ", current_step_count);

func _randomize_step_count() -> int:
	return randi_range(MIN_STEP_COUNT, MAX_STEP_COUNT);

func _randomize_step_interval() -> float:
	return randf_range(SHORTEST_STEP_INTERVAL, LONGEST_STEP_INTERVAL);

func _randomize_roam_interval() -> float:
	return randf_range(SHORTEST_ROAM_INTERVAL, LONGEST_ROAM_INTERVAL);
