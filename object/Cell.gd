@tool
class_name Cell extends Node3D

@export_group("Pieces")
@export_subgroup("Floor") 
@export var activate_floor: bool = true;
@export_subgroup("Ceiling")
@export var activate_ceiling: bool = true;
@export_subgroup("North Wall")
@export var activate_north_wall: bool = true;
@export_subgroup("East Wall")
@export var activate_east_wall: bool = true;
@export_subgroup("South Wall")
@export var activate_south_wall: bool = true;
@export_subgroup("West Wall")
@export var activate_west_wall: bool = true;

#Pieces
@onready var floor_piece: StaticBody3D = $Floor;
@onready var ceiling_piece: StaticBody3D = $Ceiling;
@onready var north_wall_piece: StaticBody3D = $WallNorth;
@onready var east_wall_piece: StaticBody3D = $WallEast;
@onready var south_wall_piece: StaticBody3D = $WallSouth;
@onready var west_wall_piece: StaticBody3D = $WallWest;

func _ready() -> void:
	handle_pieces();

func _process(delta: float) -> void:
	# Reflect changes in editor
	if Engine.is_editor_hint():
		handle_pieces();

func handle_pieces() -> void:
	# Floor
	if(not activate_floor):
		floor_piece.hide();
	else:
		floor_piece.show();
#
#	# Ceiling
	if(not activate_ceiling):
		ceiling_piece.hide();
	else:
		ceiling_piece.show();
#
#	# North Wall
	if(not activate_north_wall):
		north_wall_piece.hide();
	else:
		north_wall_piece.show();
		
	# East Wall
	if(not activate_east_wall):
		east_wall_piece.hide();
	else:
		east_wall_piece.show();
		
	# South Wall
	if(not activate_south_wall):
		south_wall_piece.hide();
	else:
		south_wall_piece.show();
		
	# West Wall
	if(not activate_west_wall):
		west_wall_piece.hide();
	else:
		west_wall_piece.show();

