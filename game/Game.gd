class_name Game extends Node3D

@onready var player: Player = $Player;
@onready var monster: Monster = $Monster;
@onready var minimap_monster_light: MinimapMonsterLight = $MinimapViewportContainer/MinimapViewport/MinimapMonsterLight;
@onready var level: Level = $Level;

var curr_cell_index: int = 0;

func _ready() -> void:
	monster.has_moved.connect(minimap_monster_light.toggle_flash);
	monster.has_moved.connect(move_monster);

func move_monster() -> void:
	monster.move(level.get_used_cells()[curr_cell_index]);
	curr_cell_index += 1;

func _process(delta: float) -> void:
	print("Player Position", Vector3i(player.position));
