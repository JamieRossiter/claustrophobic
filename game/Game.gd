## The game's main class
class_name Game extends Node3D

@onready var level: Level = preload("res://levels/TestLevel.tscn").instantiate(); ## The current level
@export var enemy: Enemy; ## The enemy object
@export var player: Player; ## The player object

func _ready() -> void:
	set_level(level);
	connect_signals();

func connect_signals() -> void:
	# When enemy takes a step, move enemy toward target index
	enemy.has_stepped.connect(move_enemy_toward_target_index);
	# When enemy performs a jumpscare whilst in JUMPSCARE state
	enemy.jumpscare.connect(teleport_enemy);
	# When enemy enters a ROAMING state
	enemy.roaming_state_set.connect(handle_roaming_state_set)

func set_level(level: Level) -> void:
	self.add_child(level);

func move_enemy_toward_target_index() -> void:
	if(not enemy.is_moving): return; # If enemy is not permitted to move, don't move
	
	if(enemy.current_state == Enums.EnemyState.AGGRO): # Check if enemy is in aggro state
		enemy.set_target_index(level.find_position_index(player.position)); # Continuously chase the 
																			# player every time the method is called.
	handle_enemy_at_target_index();
	
	enemy.move_to_position(level.get_used_cells()[enemy.current_position_index]); # Move enemy to next position
	
	handle_enemy_index_persistence();
	
	progress_enemy_index(enemy.target_index);

func progress_enemy_index(target_index: int) -> void:
	# If target index is more than enemy's current index, increase curr index (move forward)
	if(target_index > enemy.current_position_index):
		print("Current Enemy Index ", enemy.current_position_index);
		enemy.current_position_index += 1;
		enemy.direction = Enums.EnemyDirection.FORWARDS;
		print("Enemy Direction", enemy.direction);
	# Otherwise decrease curr index (move backwards)
	else:
		print("Current Enemy Index ", enemy.current_position_index);
		enemy.current_position_index -= 1;
		enemy.direction = Enums.EnemyDirection.BACKWARDS;
		print("Enemy Direction", enemy.direction);

# Check if enemy is at target index pos, if not move toward target index pos
func handle_enemy_at_target_index() -> void:
	if(enemy.current_position_index == enemy.target_index):
		enemy.stop_moving();
		randomize_enemy_target_index();
		print("Next target index ", enemy.target_index);

## Ensures Enemy doesn't stop moving (and start moving backwards) past the first or last position index. 
## Determined by the direction the enemy is moving (e.g. 0,1,2,3 = forwards | 3,2,1,0 = backwards)
func handle_enemy_index_persistence() -> void:
	if(
		level.is_index_at_end_of_level(enemy.current_position_index)  
		and enemy.direction == Enums.EnemyDirection.FORWARDS
	):
		enemy.current_position_index = 1;
		
	elif(
		level.is_index_at_start_of_level(enemy.current_position_index)
		and enemy.direction == Enums.EnemyDirection.BACKWARDS
	):
		enemy.current_position_index = level.get_used_cells().size();

func teleport_enemy() -> void:
	enemy.move_to_position(get_position_in_front_of_player(1, false));
	enemy.set_idle();

func randomize_enemy_target_index() -> void:
	enemy.set_target_index(level.find_position_index(level.get_random_position()));

func get_position_in_front_of_player(distance: int, in_front: bool) -> Vector3:
	var player_pos_index: int = level.find_position_index(player.position);
	var distance_from_player: int;
	# Spawn enemy based on the direction the player is facing
	if(player.direction == Enums.Direction.NORTH or player.direction == Enums.Direction.WEST):
		# Check if spawning in front or behind
		if(in_front):
			distance_from_player = player_pos_index + distance;
		else:
			distance_from_player = player_pos_index - distance;
	else:
		# Check if spawning in front or behind
		if(in_front):
			distance_from_player = player_pos_index - distance;
		else:
			distance_from_player = player_pos_index + distance;
	# Return the position based on distance from the player's position
	return level.find_index_position(distance_from_player);

func handle_roaming_state_set() -> void:
	enemy.set_target_index(level.find_position_index(level.get_random_position()));
