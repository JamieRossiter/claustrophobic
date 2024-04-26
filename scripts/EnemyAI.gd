extends Node

# Export vars
@export var enemy: Enemy;
@export var level: Level;
@export var player: Player;

# General vars
var is_moving: bool;
var current_direction: Enums.EnemyDirection = Enums.EnemyDirection.FORWARDS;
var current_state: Enums.EnemyState;
var current_position_index: int;
var current_target_index: int;
var current_step_count: int = 0;

# Step interval constants
const MIN_STEP_INTERVAL: float = 0.5;
const MAX_STEP_INTERVAL: float = 1.0;

# Step count constants
const NO_STEP_COUNT: int = 0;
const MIN_STEP_COUNT: int = 2;
const MAX_STEP_COUNT: int = 10;
const AGGRO_STEP_COUNT: int = 999;

# Move interval constants
const AGGRO_MOVE_INTERVAL: float = 0.1;
const MIN_MOVE_INTERVAL: float = 5.0;
const MAX_MOVE_INTERVAL: float = 10.0;

# Timers
@onready var time_to_next_step: Timer = Timer.new(); # Interval timer between steps
@onready var time_to_next_move: Timer = Timer.new(); # Interval timer between a series of steps

func _ready() -> void:
	current_state = Enums.EnemyState.IDLE;
	current_position_index = level.get_index_from_position(enemy.position);
	current_target_index = self._get_target_index();
	_init_timers();
	_start_moving();

func _init_timers() -> void:
	_init_time_to_next_move();
	_init_time_to_next_step();

func _init_time_to_next_step() -> void:
	self.add_child(time_to_next_step);
	time_to_next_step.timeout.connect(_step_toward_target_index);

func _init_time_to_next_move() -> void:
	self.add_child(time_to_next_move);
	time_to_next_move.timeout.connect(_start_moving);

# Get target index based on enemy state
func _get_target_index() -> int:
	var index: int;
	match(self.current_state):
		Enums.EnemyState.IDLE:
			index = -1; # No target index
		Enums.EnemyState.ROAMING:
			index = level.get_random_index();
		Enums.EnemyState.AGGRO:
			index = level.get_index_from_position(player.position); # Player index
	return index;

func _start_moving() -> void:
	if(current_state == Enums.EnemyState.IDLE): 
		_stop_moving();
		return;
	is_moving = true;
	# Get the target index based on state
	current_target_index = self._get_target_index();
	# Set step count
	current_step_count = self._determine_step_count();
	# Take first step after move start
	self._step_toward_target_index();

# Stop moving temporarily
func _stop_stepping() -> void:
	is_moving = false;
	time_to_next_step.stop();
	# Determine when to start moving again
	time_to_next_move.wait_time = self._determine_move_interval();
	time_to_next_move.start();

# Stop moving permanently
func _stop_moving() -> void:
	is_moving = false;
	time_to_next_move.stop();
	time_to_next_step.stop();
	current_state = Enums.EnemyState.IDLE;

func _step_toward_target_index() -> void:
	# DEBUG
	print("New Target Index ", current_target_index);
	print("Current Pos Index ", current_position_index);
	print("Current Target Index ", current_target_index);
	print("Current step count ", current_step_count);

	# Temporarily stop if the target index has been reached or if current step count is depleted
	if(not is_moving or self._target_index_reached() or current_step_count <= 0):
		self._stop_stepping();
		return;

	# If aggro, continuously chase the player by getting their position every step
	if(current_state == Enums.EnemyState.AGGRO):
		current_target_index = self._get_target_index();

	# Increase or decrease current position index based on enemy direction
	match(self._get_direction()):
		Enums.EnemyDirection.FORWARDS:
			# Persist forwards momentum when crossing the level end/start border
			if(level.is_index_at_end_of_level(current_position_index)):
				current_position_index = 0;
			else:
				current_position_index += 1;
		Enums.EnemyDirection.BACKWARDS: 
			# Persist backwards momentum when crossing the level start/end border
			if(level.is_index_at_start_of_level(current_position_index)):
				current_position_index = level.get_used_cells().size();
			else:
				current_position_index -= 1;
			
	# Emit enemy_step signal, passing new position as argument
	Signals.enemy_step.emit(level.get_position_from_index(current_position_index));

	# Determine how long before next step, then activate interval timer
	time_to_next_step.wait_time = self._determine_step_interval();
	time_to_next_step.start();

	# Negate a step from step count
	current_step_count -= 1;

func _get_direction() -> Enums.EnemyDirection:
	var direction: Enums.EnemyDirection;

	# INVERSE DIRECTION METHOD
	# TODO: Make this a function
	# If player idx more than half and enemy idx less than half of level start index, maintain backwards direction for momentum persistence
	if(current_state == Enums.EnemyState.AGGRO):
		if([0,1,2,3,4,5,6,7,8,9,10].has(current_position_index) and [29,28,27,26,25,24,23,22,21,20].has(level.get_index_from_position(player.position))):
			return Enums.EnemyDirection.BACKWARDS;
		elif([29,28,27,26,25,24,23,22,21,20].has(current_position_index) and [0,1,2,3,4,5,6,7,8,9,10].has(level.get_index_from_position(player.position))):
			return Enums.EnemyDirection.FORWARDS;
		else:
			pass;
		
	# If target index is more than enemy's current index, set direction forwards
	if(current_target_index > current_position_index):
		direction = Enums.EnemyDirection.FORWARDS;
	# Otherwise set direction backwards
	else:
		direction = Enums.EnemyDirection.BACKWARDS;
	return direction;

# Determine how long the interval is between a series of steps
func _determine_move_interval() -> float:
	var interval: float;
	match(current_state):
		Enums.EnemyState.AGGRO:
			interval = AGGRO_MOVE_INTERVAL;
		Enums.EnemyState.ROAMING:
			interval = self._get_random_move_interval();
	return interval;

func _determine_step_interval() -> float:
	var interval: float;
	match(self.current_state):
		Enums.EnemyState.AGGRO:
			interval = MIN_STEP_INTERVAL; # Move as quickly as possible; create urgency
		Enums.EnemyState.ROAMING:
			interval = _get_random_step_interval();
	return interval;

func _determine_step_count() -> int:
	var count: int;
	match(self.current_state):
		Enums.EnemyState.IDLE:
			count = NO_STEP_COUNT; # No steps
		Enums.EnemyState.AGGRO:
			count = AGGRO_STEP_COUNT; # "Infinite" steps; enemy never stops moving towards target
		Enums.EnemyState.ROAMING:
			count = _get_random_step_count();
	return count;

func _target_index_reached() -> bool:
	return current_position_index == self.current_target_index;

func _get_random_step_interval() -> float:
	return randf_range(MIN_STEP_INTERVAL, MAX_STEP_INTERVAL);

func _get_random_move_interval() -> float:
	return randf_range(MIN_MOVE_INTERVAL, MAX_MOVE_INTERVAL);

func _get_random_step_count() -> int:
	return randi_range(MIN_STEP_COUNT, MAX_STEP_COUNT);

