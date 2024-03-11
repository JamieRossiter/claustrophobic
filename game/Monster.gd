class_name Monster extends CharacterBody3D

var original_pos: Vector3;
var target: Vector3; # The target the pathfinding algorithm seeks out

@onready var time_to_next_move: Timer = Timer.new();
@onready var game: Game = get_parent();

signal has_moved;

func _ready() -> void:
	original_pos = self.position;
	init_move_timer();

func init_move_timer() -> void:
	time_to_next_move.wait_time = 3;
	add_child(time_to_next_move);
	time_to_next_move.timeout.connect(emit_move);
	time_to_next_move.start();

func emit_move() -> void:
	has_moved.emit();
	time_to_next_move.start();
	
func move(cell: Vector3i):
	self.position = Vector3(cell) + original_pos;
	
