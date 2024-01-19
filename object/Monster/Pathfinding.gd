class_name Pathfinding extends Node3D

@onready var astar_grid: AStarGrid2D = AStarGrid2D.new();
@onready var monster: Monster = get_parent();
@onready var level: Level = monster.get_parent();
var tile_map: TileMap;
var player: Player;
var target: Vector3; # The target the pathfinding algorithm seeks out

func _process(delta: float) -> void:
	if(not tile_map):
		tile_map = level.tile_map;
		player = level.player;
		set_target();
		astar_grid.size = tile_map.get_used_rect().size;
		astar_grid.cell_size = Vector2(tile_map.cell_quadrant_size, tile_map.cell_quadrant_size);
		astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER;
		astar_grid.update();
		make_cells_impassable(get_empty_cells());
		
func set_target() -> void:
	if(monster.is_aggro):
		target = player.position;
	else:
		target = get_random_vent_cell_target();
		pass;

# Gets a random vent cell target (for indiscriminate roaming)
func get_random_vent_cell_target() -> Vector3:
	var vent_cells: Array[VentCell] = level.vent_cells;
	var target_vc: VentCell = vent_cells[randi() % vent_cells.size()];
	return level.get_closest_vent_cell_position_to_position(target_vc.position);

func get_astar_path() -> Array[Vector2i]:
	# HACK: Monster's true position does not correlate to TileMap position. 
	# Dividing the monster and player positions by 0.6 appears to fix the issue, 
	# however because get_id_path requires Vector2i, the floats in the supplied 
	# Vector2s are being implicitly cast to ints, which adds some error and makes 
	# this fix imperfect. THIS COULD AFFECT PATHING LATER DOWN THE TRACK.
	return astar_grid.get_id_path(
		Vector2(monster.position.x / 0.6, monster.position.z / 0.6), 
		Vector2(target.x / 0.6, target.z / 0.6)
	);

func get_empty_cells() -> Array[Vector2i]:
	var empty_cell_positions: Array[Vector2i] = [];
	var used_rect: Rect2 = tile_map.get_used_rect();
	for x in (used_rect.size.x - 1):
		for y in used_rect.size.y:
			var cell_pos: Vector2i = Vector2i(x, y);
			var tile_data: TileData = tile_map.get_cell_tile_data(0, cell_pos);
			if(not tile_data):
				empty_cell_positions.append(cell_pos);
	return empty_cell_positions;

func make_cells_impassable(cells: Array[Vector2i]) -> void:
	for cell in cells:
		astar_grid.set_point_solid(cell, true);
