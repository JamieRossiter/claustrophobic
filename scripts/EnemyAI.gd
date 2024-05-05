extends Node

# Export vars
@export var enemy: Enemy;
@export var level: Level;
@export var player: Player;

# General vars
var is_moving: bool;
var is_visible_onscreen: bool = false;

@onready var last_player_direction: Enums.Direction = player.direction;
@onready var last_player_position_index: int = level.get_index_from_position(player.position);

var current_direction: Enums.EnemyDirection = Enums.EnemyDirection.FORWARDS;
var current_state: Enums.EnemyState;
var current_position_index: int;
var current_target_index: int;
var current_step_count: int = 0;

# Step interval constants
const MIN_STEP_INTERVAL: float = 1.5;
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
	current_state = Enums.EnemyState.ROAMING;
	# Set the current target index based on default state (should be idle)
	current_target_index = self._get_target_index();
	# Set current position index to enemy's current position during init
	current_position_index = level.get_index_from_position(enemy.position);
	self._init_timers();
	self._start_moving();

func _physics_process(delta):
#	print("Enemy Position: ", enemy.position);
#	print("Player Position: ", player.position);
	pass;

func _init_timers() -> void:
	self._init_time_to_next_move();
	self._init_time_to_next_step();

func _init_time_to_next_step() -> void:
	self.add_child(time_to_next_step);
	time_to_next_step.timeout.connect(_step);

func _init_time_to_next_move() -> void:
	self.add_child(time_to_next_move);
	time_to_next_move.timeout.connect(_start_moving);

# Get target index based on enemy state
func _get_target_index() -> int:
	var index: int;
	match(self.current_state):
		Enums.EnemyState.IDLE, Enums.EnemyState.AGGRO:
			index = -1; # No target index
		Enums.EnemyState.ROAMING:
			index = level.get_random_index();
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
	self._step();

# Stop moving temporarily
func _stop_stepping() -> void:
	is_moving = false;
	time_to_next_step.stop();
	# Determine when to start moving again
	time_to_next_move.wait_time = self._get_random_move_interval();
	time_to_next_move.start();

# Stop moving permanently
func _stop_moving() -> void:
	is_moving = false;
	time_to_next_move.stop();
	time_to_next_step.stop();
	current_state = Enums.EnemyState.IDLE;

func _step() -> void:
	# DEBUG
	print("Current Pos Index ", current_position_index);
	print("Current Target Index ", current_target_index);
	print("Current step count ", current_step_count);
	print("Last player index ", last_player_position_index);
	print("Current player index ", level.get_index_from_position(player.position));
	
	# If the player is looking at enemy, stop moving for the duration the player is looking
	if(is_visible_onscreen and current_state == Enums.EnemyState.AGGRO):
		return;
	
	# Temporarily stop if the target index has been reached or if current step count is depleted
	if(not is_moving or self._target_index_reached() or current_step_count <= 0):
		self._stop_stepping();
		return;
	
	# Handle step behaviours based on enemy state
	match(current_state):
		Enums.EnemyState.IDLE:
			self._stop_moving();
		Enums.EnemyState.AGGRO:
			self._chase_player();
		Enums.EnemyState.ROAMING:
			self._step_toward_target_index();
			
	# Emit enemy_step signal, passing new position as argument
	Signals.enemy_step.emit(level.get_position_from_index(current_position_index));

	# Determine how long before next step, then activate interval timer
	time_to_next_step.wait_time = self._determine_step_interval();
	time_to_next_step.start();

	# Negate a step from step count
	current_step_count -= 1;

func _step_toward_target_index() -> void:
	match(self._get_direction()):
		Enums.EnemyDirection.FORWARDS:
			current_position_index += 1;
		Enums.EnemyDirection.BACKWARDS: 
			current_position_index -= 1;

# Continuously 'chase' the player by being one index in front or behind them
func _chase_player() -> void:
	var current_player_position_index: int = level.get_index_from_position(player.position);
	
	# If the player's position hasn't changed, game over
	if(last_player_position_index == current_player_position_index):
		current_position_index = current_player_position_index;
		print("Game Over!");
		return;
		
	#  Check if at level boundaries
	if(level.is_index_at_level_boundaries(last_player_position_index)):
		current_position_index = last_player_position_index;
	else:
		# If player's next position index is smaller than the last position index, spawn -1 index
		if(last_player_position_index < current_player_position_index):
			current_position_index = current_player_position_index - 1;
		# If the player's next position index is greater than the last position index, spawn +1 index
		elif(last_player_position_index > current_player_position_index):
			current_position_index = current_player_position_index + 1;
			
	last_player_position_index = current_player_position_index;		

func _get_direction() -> Enums.EnemyDirection:
	var direction: Enums.EnemyDirection;

	# If target index is more than enemy's current index, set direction forwards
	if(current_target_index > current_position_index):
		direction = Enums.EnemyDirection.FORWARDS;
	else:
		# Otherwise set direction backwards
		direction = Enums.EnemyDirection.BACKWARDS;
		
	return direction;

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

func _get_opposite_direction(direction: Enums.Direction) -> Enums.Direction:
	return {
		Enums.Direction.NORTH: Enums.Direction.SOUTH,
		Enums.Direction.SOUTH: Enums.Direction.NORTH,
		Enums.Direction.EAST: Enums.Direction.WEST,
		Enums.Direction.WEST: Enums.Direction.EAST
	}[direction]

func _on_visible_on_screen_enabler_3d_screen_entered():
	is_visible_onscreen = true;

func _on_visible_on_screen_enabler_3d_screen_exited():
	is_visible_onscreen = false;
