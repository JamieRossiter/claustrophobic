class_name Monster extends CharacterBody3D

const SPEED: float = 2.0;
@onready var pathfinder: Pathfinding = $Pathfinding;
var path_index: int = 0;
var path;

func _ready() -> void:
	start_path_find_timer();

func start_path_find_timer() -> void:
	var timer: Timer = Timer.new();
	timer.wait_time = 3;
	add_child(timer);
	timer.timeout.connect(on_path_find_timeout);
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
		position.x = path[path_index].x
		position.z = path[path_index].y;
