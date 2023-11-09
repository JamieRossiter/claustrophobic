class_name Level extends Node3D

@export var CurrentMap: PackedScene = null;
var vent_cells: Array[VentCell] = [];
@onready var player: Player = $Player;

func _ready() -> void:
	var map_data: Array[Vector2i] = get_map_data(); 
	generate_map(map_data);
	player.position.x = vent_cells[0].position.x;
	player.position.y = vent_cells[0].position.y;

func get_map_data() -> Array[Vector2i]:
	if(not CurrentMap is PackedScene): return [];
	var map: TileMap = CurrentMap.instantiate();
	var used_tiles: Array[Vector2i] = map.get_used_cells(0);
	map.queue_free();
	return used_tiles;

func generate_map(map_data: Array[Vector2i]) -> void:
	for tile in map_data:
		var vent_cell: VentCell = VentCell.new();
		add_child(vent_cell);
		vent_cell.position = Vector3((tile.x * 0.6), 0, (tile.y * 0.6));
		vent_cells.append(vent_cell);
		for cell in vent_cells:
			cell.update_walls(map_data);
	

