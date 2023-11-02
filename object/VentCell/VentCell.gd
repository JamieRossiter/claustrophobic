@tool
class_name VentCell extends Node3D

const VentSection: PackedScene = preload("res://object/VentCell/VentSection.tscn");

@onready var north_wall: VentSection = VentSection.instantiate();
@onready var south_wall: VentSection = VentSection.instantiate();
@onready var east_wall: VentSection = VentSection.instantiate()
@onready var west_wall: VentSection = VentSection.instantiate()
@onready var ceiling: VentSection = VentSection.instantiate()
@onready var floor: VentSection = VentSection.instantiate()

const FLOOR_WIDTH: float = 0.6;
const WALL_HEIGHT: float = 0.3;

func _ready() -> void:
	add_sections_to_tree();
	setup_sections();

func add_sections_to_tree() -> void:
	add_child(north_wall);
	add_child(south_wall);
	add_child(east_wall);
	add_child(west_wall);
	add_child(floor);
	add_child(ceiling);

func setup_sections() -> void:
	setup_floor_ceiling(floor, false);
	setup_floor_ceiling(ceiling, true);
	setup_wall(north_wall, "north");
	setup_wall(south_wall, "south");
	setup_wall(east_wall, "east");
	setup_wall(west_wall, "west");

func setup_floor_ceiling(section: VentSection, is_ceiling: bool) -> void:
	# Configure mesh
	var meshInstance: MeshInstance3D = section.get_node("MeshInstance3D");
	var mesh: PlaneMesh = meshInstance.mesh;
	mesh.size.x = FLOOR_WIDTH;
	mesh.size.y = FLOOR_WIDTH;
	if(is_ceiling):
		section.position.y = WALL_HEIGHT;
		mesh.flip_faces = true;

func setup_wall(wall: VentSection, direction: String) -> void:
	# Configure mesh
	var meshInstance: MeshInstance3D = wall.get_node("MeshInstance3D");
	var mesh: PlaneMesh = meshInstance.mesh;
	mesh.size.y = WALL_HEIGHT;
	# Configure static body
	wall.rotate_x(deg_to_rad(90));
	wall.position.y = mesh.size.y / 2;
	match(direction):
		"north":
			wall.position.z = -0.30;
			mesh.size.x = FLOOR_WIDTH;
		"south":
			wall.position.z = 0.30; 
			mesh.size.x = FLOOR_WIDTH;
			mesh.flip_faces = true;
		"east":
			wall.position.x = FLOOR_WIDTH / 2;
			wall.rotate_y(deg_to_rad(90));
			mesh.size.x = FLOOR_WIDTH;
			mesh.flip_faces = true;
			mesh.subdivide_depth = 100;
			mesh.subdivide_width = 100;
		"west":
			wall.position.x = -FLOOR_WIDTH / 2;
			mesh.size.x = FLOOR_WIDTH;
			wall.rotate_y(deg_to_rad(90));
	# Configure collision
	var collisionShape: CollisionShape3D = wall.get_node("CollisionShape3D");
	collisionShape.get_shape().set_size(Vector3(mesh.size.x, mesh.size.y, 0));
	collisionShape.rotate_x(deg_to_rad(90));
	
func update_walls(map_data: Array[Vector2i]) -> void:
	# FIXME: The walls only update correctly if a Vector2i is used with integers. As soon as we multiply or divide the position values by a float, the walls don't update correctly. Is there a way we can convert the Vector2i to a Vector2? The Vector2i originates from the TileMap.get_used_cells() method in Level.gd.
	var current_grid_pos: Vector2i = Vector2i(position.x, position.z);
	if(map_data.has(current_grid_pos + Vector2i.UP)):
		north_wall.queue_free();
	if(map_data.has(current_grid_pos + Vector2i.DOWN)):
		south_wall.queue_free();
	if(map_data.has(current_grid_pos + Vector2i.LEFT)):
		west_wall.queue_free();
	if(map_data.has(current_grid_pos + Vector2i.RIGHT)):
		east_wall.queue_free();
