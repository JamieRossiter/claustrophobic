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
	randomize_monster_position();
	
func _process(delta):
	teleport_monster_near_player();

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

# Returns the closest valid vent cell position to the position provided as an argument
func get_closest_vent_cell_position_to_position(position: Vector3) -> Vector3:
	var snapped_position: Vector3 = Vector3(snapped(position.x, 0.1), snapped(position.y, 0), snapped(position.z, 0.1))
	# Separate vent cell x values
	var vent_cell_xs: Array = vent_cells.map(func(vc): return vc.position.x);
	# Separate vent cell z values
	var vent_cell_zs: Array = vent_cells.map(func(vc): return vc.position.z);
	return Vector3(find_closest(snapped_position.x, vent_cell_xs), snapped_position.y, find_closest(snapped_position.z, vent_cell_zs));

# Get the position of the vent cell in its array based on the provided position
func get_vent_cell_arraypos_by_position(position: Vector3) -> int:
	# Sanitise the provided position by getting the position of the vent cell closest to it.												
	var valid_vent_cell_pos: Vector3 = get_closest_vent_cell_position_to_position(position);
	var arraypos: int = -1;
	if(not valid_vent_cell_pos): return arraypos; # if not valid vent cell, gtfo
	
	for i in range(vent_cells.size()):
		if(valid_vent_cell_pos == vent_cells[i].position):
			arraypos = i;
	return arraypos;	

# TODO: Move this function to a utility script
func find_closest(num, array):
	var best_match = null
	var least_diff = 2147483647;

	for number in array:
		var diff = abs(num - number)
		if(diff < least_diff):
			best_match = number
			least_diff = diff
			
	return best_match

func set_player_position() -> void:
	player.position.x = vent_cells[15].position.x;
	player.position.y = vent_cells[15].position.y;
	player.position.z = vent_cells[15].position.z;

func randomize_monster_position() -> void:
	monster.position.x = vent_cells[randi() % vent_cells.size()].position.x;
	monster.position.y = vent_cells[randi() % vent_cells.size()].position.y + 0.15;
	monster.position.z = vent_cells[randi() % vent_cells.size()].position.z;

# FIXME: Why are the vent cell arraypos's random? Adjacent cells jump from 15 to 29?
func teleport_monster_near_player() -> void:
	var vent_cell_arraypos: int = get_vent_cell_arraypos_by_position(player.position);
	print("arraypos ", vent_cell_arraypos);
#	if(target_pos):
#		monster.position = Vector3(target_pos.x, target_pos.y, target_pos.z);
