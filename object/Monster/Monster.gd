class_name Monster extends CharacterBody3D

const SPEED: float = 2.0;

var path_index: int = 0;
var path;

@onready var pathfinder: Pathfinding = $Pathfinding;
@onready var footstep_distant: AudioStreamPlayer3D = $FootstepDistant;
@onready var footstep_close: AudioStreamPlayer3D = $FootstepClose;
@onready var breathing: AudioStreamPlayer3D = $Breathing;

func _ready() -> void:
	start_path_find_timer();
	start_footstep_timer();
	start_breathing_timer();
	pass;

func start_path_find_timer() -> void:
	var timer: Timer = Timer.new();
	timer.wait_time = 3;
	add_child(timer);
	timer.timeout.connect(on_path_find_timeout);
	timer.start();
	
func start_footstep_timer() -> void:
	var timer: Timer = Timer.new();
	timer.wait_time = 0.5;
	add_child(timer);
	timer.timeout.connect(play_footstep_sound);
	timer.start();
	
func start_breathing_timer() -> void:
	var timer: Timer = Timer.new();
	timer.wait_time = 3;
	add_child(timer);
	timer.timeout.connect(play_breathing_sound);
	timer.start();

func on_path_find_timeout() -> void:
	if(not path):
		path = pathfinder.get_astar_path();
		print(path);
	else:
		if(path_index >= path.size() - 1):
			path_index = 0;
			path = pathfinder.get_astar_path();
			print(path);
		else:
			path_index += 1;
		position.x = path[path_index].x;
		position.z = path[path_index].y;
		print(Vector2(position.x, position.z));

func play_footstep_sound() -> void:
	footstep_distant.play();
	footstep_close.play();

func play_breathing_sound() -> void:
	breathing.play();
