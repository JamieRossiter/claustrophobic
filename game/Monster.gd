class_name Monster extends CharacterBody3D

var original_pos: Vector3;
@onready var time_to_next_move: Timer = Timer.new();
signal has_moved;

func _ready() -> void:
	original_pos = self.position;
	print(original_pos);
	init_move_timer();

func init_move_timer() -> void:
	time_to_next_move.wait_time = 3;
	add_child(time_to_next_move);
	time_to_next_move.timeout.connect(emit_move);
	time_to_next_move.start();

func emit_move() -> void:
	has_moved.emit();
	time_to_next_move.start();
	
func move(random_cell: Vector3i):
	self.position = Vector3(random_cell) + original_pos;
