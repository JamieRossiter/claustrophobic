"""
Level.gd
Handles all logic for the 'Level' class, which is a customisable GridMap node 
that determines the layout of each level in the game.
"""
class_name Level extends GridMap

func _ready() -> void:
	create_minimap_meshes(get_used_cells());

func create_minimap_meshes(used_cells: Array[Vector3i]) -> void:
	print(used_cells);
	for uc in used_cells:
		var pm: PlaneMesh = PlaneMesh.new();
		pm.size.x = 1;
		pm.size.y = 1;
		var mi: MeshInstance3D = MeshInstance3D.new();
		mi.mesh = pm;
		mi.position = map_to_local(uc);
		mi.set_layer_mask_value(1, false);
		mi.set_layer_mask_value(20, true);
		add_child(mi);

func find_position_index(pos: Vector3) -> int:
	var posIndex = 0;
	for i in range(self.get_used_cells().size()):
		if(self.get_used_cells()[i] == Vector3i(pos)): posIndex = i;
	return posIndex;
	
func find_index_position(idx: int) -> Vector3:
	return self.get_used_cells()[idx];

func get_random_position() -> Vector3:
	var uc: Array = get_used_cells();
	return get_used_cells()[randi_range(0, uc.size() - 1)];
	
func is_index_at_end_of_level(index: int) -> bool:
	return index == get_used_cells().size();

func is_index_at_start_of_level(index: int) -> bool:
	return index == 0;
