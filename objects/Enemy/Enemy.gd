class_name Enemy extends CharacterBody3D

# General variables
var original_position: Vector3;
var current_position_index: int;
# Timers
@onready var time_to_next_move: Timer = Timer.new();
# Signals
signal has_moved;

func _ready() -> void:
	init_move_timer();
	original_position = self.position;

func init_move_timer() -> void:
	time_to_next_move.wait_time = 3;
	add_child(time_to_next_move);
	time_to_next_move.timeout.connect(emit_move);
	time_to_next_move.start();

func emit_move() -> void:
	has_moved.emit();
	time_to_next_move.start();
	
func move_to_position(cell: Vector3i):
	self.position = Vector3(cell) + original_position;
