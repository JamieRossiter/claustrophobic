# Level.gd
# Author: Jamie Rossiter
# Last Updated: 28/04/24
# Handles all data and logic for Levels

class_name Level extends GridMap

func _ready():
	create_minimap_meshes(get_used_cells());
	pass;

func create_minimap_meshes(used_cells: Array[Vector3i]) -> void:
	print(used_cells);
	for uc in used_cells:
		var pm: PlaneMesh = PlaneMesh.new();
		pm.size.x = 2;
		pm.size.y = 2;
		var mi: MeshInstance3D = MeshInstance3D.new();
		mi.mesh = pm;
		mi.position = map_to_local(uc);
		mi.set_layer_mask_value(1, false);
		mi.set_layer_mask_value(10, true);
		add_child(mi);

# Takes a Vector3 position, finds the closes vent cell position and returns the corresponding level's cell index
func get_index_from_position(pos: Vector3) -> int:
	var closest_pos: Vector3 = self._find_closest_vent_cell_position_to_position(pos);
	var pos_index;
	for i in range(self.get_used_cells().size()):
		if(self.get_used_cells()[i] == Vector3i(closest_pos)): pos_index = i;
	return pos_index;

# Takes a level cell index and returns the Vector3 position
func get_position_from_index(idx: int) -> Vector3:
	return self.get_used_cells()[idx];

func get_random_position() -> Vector3:
	var uc: Array = get_used_cells();
	return get_used_cells()[randi_range(0, uc.size() - 1)];

func get_random_index() -> int:
	return self.get_index_from_position(self.get_random_position());

func is_index_at_end_of_level(index: int) -> bool:
	return index == get_used_cells().size() - 1;

func is_index_at_start_of_level(index: int) -> bool:
	return index == 0;

# Returns the closest valid vent cell position to the position provided as an argument
func _find_closest_vent_cell_position_to_position(pos: Vector3) -> Vector3:
	var snapped_position: Vector3 = Vector3(snapped(pos.x, 0.1), snapped(pos.y, 0), snapped(pos.z, 0.1))
	
	# Separate vent cell x values
	var vent_cell_xs: Array = get_used_cells().map(func(vc): return vc.x);
	
	# Separate vent cell z values
	var vent_cell_zs: Array = get_used_cells().map(func(vc): return vc.z);
	
	return Vector3(find_closest(snapped_position.x, vent_cell_xs), snapped_position.y, find_closest(snapped_position.z, vent_cell_zs));

# TODO: Make this a util function
func find_closest(num, array):
	var best_match = null
	var least_diff = 2147483647;

	for number in array:
		var diff = abs(num - number)
		if(diff < least_diff):
			best_match = number
			least_diff = diff
			
	return best_match
