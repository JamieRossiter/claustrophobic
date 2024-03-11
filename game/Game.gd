class_name Game extends Node3D

@onready var monster: Monster = $Monster;
@onready var minimap_monster_light: MinimapMonsterLight = $MinimapViewportContainer/MinimapViewport/MinimapMonsterLight;
@onready var level: Level = $Level;

func _ready() -> void:
	monster.has_moved.connect(minimap_monster_light.toggle_flash);
	monster.has_moved.connect(move_monster);

func move_monster() -> void:
	monster.move(Vector3i(0, 0, 0));
