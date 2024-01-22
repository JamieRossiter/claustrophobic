class_name Level extends Node3D

enum MonsterTeleportOrientation {
	IN_FRONT,
	BEHIND
}

var vent_cells: Array[VentCell] = [];
var tile_map: TileMap;
var is_game_over: bool = false; # TESTING: Game over toggle

@export var map_scene: PackedScene;
@onready var player: Player = $Player;
@onready var monster: Monster = $Monster;
@onready var splash_screen: SplashScreen = $SplashScreen;

# Sounds
@onready var metal_impact_timer: Timer = Timer.new();
@onready var metal_creak_timer: Timer = Timer.new();
@onready var vent_ambience: AudioStreamPlayer = $VentAmbience;
@onready var metal_impact: AudioStreamPlayer = $VentAmbience/MetalImpact;
@onready var metal_creak: AudioStreamPlayer = $VentAmbience/MetalCreak;

func _ready() -> void:
	tile_map = map_scene.instantiate();
	var map_data: Array[Vector2i] = get_map_data(); 
	generate_map(map_data);
	spawn_player();
	spawn_monster_furthest_from_player();
	splash_screen.show_intro_screen();
	init_ambience();
	
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

func reset_level() -> void:
	spawn_player();
	spawn_monster_furthest_from_player();
	pass;

func spawn_player() -> void:
	set_player_position(Vector3(0,0,0));

func get_vent_cell_from_position(position: Vector3) -> VentCell:
	var target_cell: VentCell = null;
	for cell in vent_cells:
		if(cell.position == position):
			target_cell = cell;
			break;
	return target_cell;
	
# Returns the closest valid vent cell position to the position provided as an argument
func get_closest_vent_cell_position_to_position(position: Vector3) -> Vector3:
	var snapped_position: Vector3 = Vector3(snapped(position.x, 0.1), snapped(position.y, 0), snapped(position.z, 0.1))
	# Separate vent cell x values
	var vent_cell_xs: Array = vent_cells.map(func(vc): return vc.position.x);
	# Separate vent cell z values
	var vent_cell_zs: Array = vent_cells.map(func(vc): return vc.position.z);
	return Vector3(Util.find_closest(snapped_position.x, vent_cell_xs), snapped_position.y, Util.find_closest(snapped_position.z, vent_cell_zs));

func set_player_position(vent_cell_pos: Vector3) -> void:
	player.position = get_closest_vent_cell_position_to_position(vent_cell_pos);

#func randomize_monster_position() -> void:
#	var target_position: Vector3 = Vector3();
#	target_position.x = vent_cells[randi() % vent_cells.size()].position.x
#	target_position.y = vent_cells[randi() % vent_cells.size()].position.y + 0.15;
#	target_position.z = vent_cells[randi() % vent_cells.size()].position.z;
#	var new_position: Vector3 = get_closest_vent_cell_position_to_position(target_position);
#	print("New Randomized Monster Position", new_position);
#	monster.position = new_position;

func spawn_monster_furthest_from_player() -> void:
	var vc_positions: Array = vent_cells.map(func(vc): return vc.position);
	var pos = Util.find_largest_vector(vc_positions)
#	monster.position = Vector3(8.4, 0, 10.2);
	monster.position = pos;

func teleport_monster_to_player(distance: int, orientation: MonsterTeleportOrientation) -> void:
	var valid_player_pos: Vector3 = get_closest_vent_cell_position_to_position(player.position);
	var current_vent_cell: VentCell = get_vent_cell_from_position(valid_player_pos);
	var target_vent_cell_pos: Vector3 = Vector3.ZERO;
	
	# Check if vent cell is going in north/south direction or east/west direction
	match(current_vent_cell.direction):
		Enum.VentDirection.NORTH_SOUTH:		
			target_vent_cell_pos = get_target_vent_cell_pos(orientation, valid_player_pos, Vector3(0, 0, distance));
		Enum.VentDirection.EAST_WEST:
			target_vent_cell_pos = get_target_vent_cell_pos(orientation, valid_player_pos, Vector3(distance, 0, 0));
					
	monster.position = target_vent_cell_pos;

# Get a particular vent cell position based on orientation, a valid vent cell position and an offset Vector3
func get_target_vent_cell_pos(orientation: MonsterTeleportOrientation, valid_pos: Vector3, offset_vector: Vector3) -> Vector3:
	var target_vector: Vector3 = Vector3.ZERO;
	
	match(player.dir):
		Enum.Direction.NORTH, Enum.Direction.EAST:
			if(orientation == MonsterTeleportOrientation.IN_FRONT):
				target_vector = valid_pos + -offset_vector;
			elif(orientation == MonsterTeleportOrientation.BEHIND):
				target_vector = valid_pos + offset_vector;
			
		Enum.Direction.SOUTH, Enum.Direction.WEST:
			if(orientation == MonsterTeleportOrientation.IN_FRONT):
				target_vector = valid_pos + offset_vector;
			elif(orientation == MonsterTeleportOrientation.BEHIND):
				target_vector = valid_pos + -offset_vector;		
			
	return target_vector;

func teleport_monster_near_player() -> void:
	pass;
#	teleport_monster_to_player(1, MonsterTeleportOrientation.IN_FRONT);

func handle_game_over() -> void:
	is_game_over = true;
	monster.stop();
	splash_screen.show_gameover_screen();
	reset_level();

func init_ambience() -> void:
	vent_ambience.play();
	init_metal_impact_timer();
	init_metal_creak_timer();
	
func init_metal_impact_timer() -> void:
	metal_impact_timer.wait_time = 10;
	add_child(metal_impact_timer);
	metal_impact_timer.timeout.connect(play_metal_impact_sound);
	metal_impact_timer.start();

func init_metal_creak_timer() -> void:
	metal_creak_timer.wait_time = 13.5;
	add_child(metal_creak_timer);
	metal_creak_timer.timeout.connect(play_metal_creak_sound);
	metal_creak_timer.start();

func play_metal_impact_sound() -> void:
	metal_impact.play();

func play_metal_creak_sound() -> void:
	metal_creak.play();
