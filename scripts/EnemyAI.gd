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
	# Set default state to idle
	current_state = Enums.EnemyState.IDLE;
	# Set the current target index based on default state (should be idle)
	current_target_index = self._get_target_index();
	# Set current position index to enemy's current position during init
	current_position_index = level.get_index_from_position(enemy.position);
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

# Initiates enemy movement for a total move start (e.g. from IDLE to ROAMING or AGGRO) or "series of steps" start
func _start_moving() -> void:
	# If enemy state idle, stop moving enemy and prevent the rest of this function from running
	if(current_state == Enums.EnemyState.IDLE): 
		self._stop_moving();
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

	# Permanently stop if the enemy has entered an IDLE state
	if(current_state == Enums.EnemyState.IDLE):
		self._stop_moving();

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
				# Move forwards normally if not at level end/start border
				current_position_index += 1;
		Enums.EnemyDirection.BACKWARDS: 
			# Persist backwards momentum when crossing the level start/end border
			if(level.is_index_at_start_of_level(current_position_index)):
				current_position_index = level.get_used_cells().size();
			else:
				# Move backwards normally if not at level start/end border
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
	var backwards: Enums.EnemyDirection = Enums.EnemyDirection.BACKWARDS;
	var forwards: Enums.EnemyDirection = Enums.EnemyDirection.FORWARDS;

	# Handle inverse direction logic for if the enemy needs direction persistence
	if(current_state == Enums.EnemyState.AGGRO):
		if(_is_inverse_direction(backwards)):
			return backwards;
		elif(_is_inverse_direction(forwards)):
			return forwards;
		else:
			pass;

	# If target index is more than enemy's current index, set direction forwards
	if(current_target_index > current_position_index):
		direction = forwards;
	else:
		# Otherwise set direction backwards
		direction = backwards;
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

func _is_inverse_direction(inverse_direction: Enums.EnemyDirection) -> bool:
	# Get first half of level's total grid cell indices and array-ize
	var max_1_idx_count: int = floor((level.get_used_cells().size()) / 2);
	var level_half_1_indices: Array;
	for i in range(max_1_idx_count):
		level_half_1_indices.push_back(i);

	# Get second half of level's total grid cell indices and array-ize
	var max_2_idx_count: int = level.get_used_cells().size() - max_1_idx_count;
	var level_half_2_indices: Array;
	for i in range(max_1_idx_count, (max_1_idx_count + max_2_idx_count)):
		level_half_2_indices.push_back(i);

	# Determine whether the inverse direction argument is required by checking if
	# the player is on one of the first half indices and the enemy is on one of the
	# second half indices, or vice versa
	var required: bool = false;
	match(inverse_direction):
		Enums.EnemyDirection.BACKWARDS:
			required = level_half_1_indices.has(current_position_index) and level_half_2_indices.has(level.get_index_from_position(player.position));
		Enums.EnemyDirection.FORWARDS:
			required = level_half_2_indices.has(current_position_index) and level_half_1_indices.has(level.get_index_from_position(player.position));
	
	return required;

func _target_index_reached() -> bool:
	return current_position_index == self.current_target_index;

func _get_random_step_interval() -> float:
	return randf_range(MIN_STEP_INTERVAL, MAX_STEP_INTERVAL);

func _get_random_move_interval() -> float:
	return randf_range(MIN_MOVE_INTERVAL, MAX_MOVE_INTERVAL);

func _get_random_step_count() -> int:
	return randi_range(MIN_STEP_COUNT, MAX_STEP_COUNT);

