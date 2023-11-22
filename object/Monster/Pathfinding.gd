class_name Pathfinding extends Node3D

@onready var astar_grid: AStarGrid2D = AStarGrid2D.new();
@onready var monster: Monster = get_parent();
@onready var level: Level = monster.get_parent();
var tile_map: TileMap;
var player: Player;

func _process(delta: float) -> void:
	if(not tile_map):
		tile_map = level.tile_map;
		player = level.player;
		astar_grid.size = tile_map.get_used_rect().size;
		astar_grid.cell_size = Vector2(tile_map.cell_quadrant_size, tile_map.cell_quadrant_size);
		astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER;
		astar_grid.update();
		make_cells_impassable(get_empty_cells());
		print(get_empty_cells());

func get_astar_path() -> Array[Vector2i]:
	# HACK: Monster's true position does not correlate to TileMap position. Dividing the monster and player positions by 0.6 appears to fix the issue, however because get_id_path requires Vector2i, the floats in the supplied Vector2s are being implicitly cast to ints, which adds some error and makes this fix imperfect.
	return astar_grid.get_id_path(
		Vector2(monster.position.x / 0.6, monster.position.z / 0.6), 
		Vector2(player.position.x / 0.6, player.position.z / 0.6)
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


















#var navigation_id: int = -1;
#var navigation_points: Array[Vector3] = [];
#var indices: Dictionary = {};
#var map: TileMap;
#var a_star: AStarGrid2D;
#
#func set_navigation_tiles() -> void:
#	var used_cells: Array[VentCell] = level.vent_cells;
#	for i in range(used_cells.size()):
#		var cell_id: int = i;
#		var cell: VentCell = used_cells[i];
#		if(cell_id == navigation_id):
#			var point: Vector2 = Vector2(cell.position.x, cell.position.z);
#			navigation_points.append(point);
#			var index: int = indices.size();
#			indices[point] = index;
#			a_star.add_point(index, point);
#
#func connect_tiles() -> void:
#	for point in navigation_points:
#		var index: int = get_point_index(point);
#		var relative_points: Array[Vector2] = [
#			Vector2(point.x + 1, point.z),
#			Vector2(point.x - 1, point.z,),
#			Vector2(point.x, point.z + 1),
#			Vector2(point.x, point.z - 1)
#		]
#
#		for relative_point in relative_points:
#			var relative_index = get_point_index(relative_point);
#			if(relative_index == null):
#				continue;
#			if(a_star.has_point(relative_index)):
#				a_star.connect_points(index, relative_index);
#
#
#func find_path(start: Vector3, target: Vector3) -> Array[Vector3]:
#	var tile_start: Vector2i = map.local_to_map(Vector2(start.x, start.y));
#	var tile_end: Vector2i = map.local_to_map(Vector2(target.x, target.y));
#
#	var a_star_path: PackedVector3Array = a_star.get_point_path(get_point_index(Vector3(tile_start)), get_point_index(end_v3));
#	var world_path: Array[Vector3] = [];
#
#	for point in a_star_path:
#		world_path.append(map.map_to_local(point.x, point.y, point.z));
#
#	return world_path;
#
#func get_point_index(vector: Vector3) -> int:
#	if(has_approx(indices, vector)):
#		return indices[vector];
#	return -1;
#
#func has_approx(map_data: Dictionary, target: Vector3) -> bool:
#	var has: bool = false;
#	for datum in map_data.keys():
#		has = datum.is_equal_approx(target);
#		if(has): break;
#	return has;
