class_name Monster extends CharacterBody3D

const SPEED: float = 2.0;

var path_index: int = 0;
var path: Array[Vector2i];

@onready var pathfinder: Pathfinding = $Pathfinding;
@onready var hitscan: Hitscan = get_node("../Player/PlayerCamera/Hitscan");

# AudioStreamPlayers
@onready var footstep_distant: AudioStreamPlayer3D = $FootstepDistant;
@onready var footstep_close: AudioStreamPlayer3D = $FootstepClose;
@onready var breathing: AudioStreamPlayer3D = $Breathing;
@onready var hurt: AudioStreamPlayer3D = $Hurt;

# Timers
@onready var footstep_timer: Timer = Timer.new();
@onready var path_find_timer: Timer = Timer.new();
@onready var breathing_timer: Timer = Timer.new();

func _ready() -> void:
	init_path_find_timer();
	path_find_timer.start();
	
	init_footstep_timer();
	footstep_timer.start();
	
	init_breathing_timer();
	breathing_timer.start();
	
	hitscan.bullet_hit.connect(is_hit_by_bullet); # Check if player has shot at monster
	pass;

func init_path_find_timer() -> void:
	path_find_timer.wait_time = 5;
	add_child(path_find_timer);
	path_find_timer.timeout.connect(on_path_find_timeout);
	
func init_footstep_timer() -> void:
	footstep_timer.wait_time = 0.25;
	add_child(footstep_timer);
	footstep_timer.timeout.connect(play_footstep_sound);
	
func init_breathing_timer() -> void:
	breathing_timer.wait_time = 3;
	add_child(breathing_timer);
	breathing_timer.timeout.connect(play_breathing_sound);

func on_path_find_timeout() -> void:
	if(not path):
		path = pathfinder.get_astar_path();
		print("Path: ", path); 
	else:
		if(path_index >= path.size() - 1):
			path_index = 0;
			path = pathfinder.get_astar_path();
			print("Path: ", path); 
		else:
			path_index += 1;
		if(path.size() > 0):
			position.x = path[path_index].x * 0.6;
			position.z = path[path_index].y * 0.6;
			print("Monster Coords: ", Vector2(path[path_index].x, path[path_index].y));

func is_hit_by_bullet(collider: Object) -> void:
	if(collider == self):
		# Handle monster hurt
		play_hurt_sound();
		footstep_timer.stop();
		path_find_timer.stop();
		breathing_timer.stop();
	

func play_footstep_sound() -> void:
	footstep_distant.play();
	footstep_close.play();

func play_breathing_sound() -> void:
	breathing.play();

func play_hurt_sound() -> void:
	hurt.play();
	
