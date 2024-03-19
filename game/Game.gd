class_name Game extends Node3D

@onready var level: Level = preload("res://levels/TestLevel.tscn").instantiate();
@export var enemy: Enemy;
@export var player: Player;
var enemy_target_index: int;

func _ready() -> void:
	# Add level to scene tree
	self.add_child(level);
	# Init enemy target index
	set_enemy_target_index(level.find_position_index(level.get_random_position()));
	# When enemy steps, move enemy toward target index
	enemy.has_stepped.connect(move_enemy_toward_target_index);

func set_enemy_target_index(target_index: int) -> void:
	enemy_target_index = target_index;

func move_enemy_toward_target_index() -> void:
	if(not enemy.is_moving): return;
	
	# Check if enemy is in aggro mode, if so chase player
	if(enemy.is_aggro):
		set_enemy_target_index(level.find_position_index(player.position));

	# Check if enemy is at target index pos, if not move toward target index pos
	if(enemy.current_position_index == enemy_target_index):
		enemy.stop_moving();
		randomize_enemy_target_index();
		print("Reached target index ", enemy_target_index);
		return;
	
	# Move enemy to next position
	enemy.move_to_position(level.get_used_cells()[enemy.current_position_index]);
	
	# If target index is more than enemy's current index, increase curr index (move forward), otherwise decrease curr index (move backwards)
	if(enemy_target_index > enemy.current_position_index):
		enemy.current_position_index += 1;
	else:
		enemy.current_position_index -= 1;

func randomize_enemy_target_index() -> void:
	enemy_target_index = level.find_position_index(level.get_random_position());

#func _process(delta: float) -> void:
#	print("Player Position ", Vector3i($CharacterContainer/Player.position));
#	print("Player Position Index ", level.find_position_index($CharacterContainer/Player.position));
