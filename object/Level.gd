class_name Level extends Node3D

var vent_cells: Array[VentCell] = [];
var tile_map: TileMap;

@export var map_scene: PackedScene;
@onready var player: Player = $Player;
@onready var monster: Monster = $Monster;

func _ready() -> void:
	tile_map = map_scene.instantiate();
	var map_data: Array[Vector2i] = get_map_data(); 
	generate_map(map_data);
	set_player_position();
	set_monster_position();

func get_map_data() -> Array[Vector2i]:
	if(not map_scene is PackedScene): return [];
	var used_tiles: Array[Vector2i] = tile_map.get_used_cells(0);
	return used_tiles;

func generate_map(map_data: Array[Vector2i]) -> void:
	for tile in map_data:
		var vent_cell: VentCell = VentCell.new();
		add_child(vent_cell);
		vent_cell.position = Vector3((tile.x * 0.6), 0, (tile.y * 0.6));
		vent_cells.append(vent_cell);
		for cell in vent_cells:
			cell.update_walls(map_data);

func set_player_position() -> void:
	player.position.x = vent_cells[15].position.x;
	player.position.y = vent_cells[15].position.y;
	player.position.z = vent_cells[15].position.z;

func set_monster_position() -> void:
	monster.position.x = vent_cells[5].position.x;
	monster.position.y = vent_cells[5].position.y + 0.15;
	monster.position.z = vent_cells[5].position.z;

