class_name Game extends Node3D

@onready var level: Level = preload("res://levels/TestLevel.tscn").instantiate(); 

func _ready() -> void:
	# Add level to scene tree
	self.add_child(level);
	
	# When enemy moves, toggle minimap light flash
	$CharacterContainer/Enemy.has_moved.connect(
		$MinimapViewportContainer/MinimapViewport/MinimapEnemyLight.toggle_flash
	);
	
	# When enemy moves, move enemy toward target index
	$CharacterContainer/Enemy.has_moved.connect(move_enemy_toward_target_index);

func move_enemy_toward_target_index() -> void:
	# Setup variables
	var enemy: Enemy = $CharacterContainer/Enemy;
	var target_index: int = level.find_position_index($CharacterContainer/Player.position);
	var used_cells: Array = level.get_used_cells();
	
	# Check if enemy is at target index pos, if not move toward target index pos
	if(enemy.current_position_index == target_index): return;
	enemy.move_to_position(used_cells[enemy.current_position_index]);
	
	# If target index is more than enemy's current index, increase curr index (move forward), otherwise decrease curr index (move backwards)
	if(target_index > enemy.current_position_index):
		enemy.current_position_index += 1;
	else:
		enemy.current_position_index -= 1;

#func _process(delta: float) -> void:
#	print("Player Position ", Vector3i($CharacterContainer/Player.position));
#	print("Player Position Index ", level.find_position_index($CharacterContainer/Player.position));
