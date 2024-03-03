"""
LevelGrid.gd
Handles all logic for the 'LevelGrid' class, which is a customisable GridMap node 
that determines the layout of each level in the game.
"""
class_name LevelGrid extends GridMap

func _ready() -> void:
	create_minimap_meshes(get_used_cells_by_item(5));
	
func create_minimap_meshes(used_cells: Array[Vector3i]) -> void:
	for uc in used_cells:
		var pm: PlaneMesh = PlaneMesh.new();
		pm.size.x = 2;
		pm.size.y = 2;
		var mi: MeshInstance3D = MeshInstance3D.new();
		mi.mesh = pm;
		mi.position = map_to_local(uc);
		mi.set_layer_mask_value(1, false);
		mi.set_layer_mask_value(20, true);
		add_child(mi);
