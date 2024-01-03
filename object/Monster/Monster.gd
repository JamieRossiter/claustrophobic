class_name Monster extends CharacterBody3D

const SPEED: float = 2.0;

var path_index: int = 0;
var path: Array[Vector2i];
var travel_distance_in_cells: int = -1;
var is_moving: bool = false;

@onready var parent: Level = get_parent();
@onready var pathfinder: Pathfinding = $Pathfinding;
@onready var hitscan: Hitscan = get_node("../Player/PlayerCamera/Hitscan");

# AudioStreamPlayers
@onready var footstep_distant: AudioStreamPlayer3D = $FootstepDistant;
@onready var footstep_close: AudioStreamPlayer3D = $FootstepClose;
@onready var breathing: AudioStreamPlayer3D = $Breathing;
@onready var hurt: AudioStreamPlayer3D = $Hurt;

# Timers
@onready var footstep_timer: Timer = Timer.new(); # The time it takes between footsteps
@onready var travel_delay_timer: Timer = Timer.new(); # The time it takes between stopping and starting during pathfinding
@onready var path_travel_timer: Timer = Timer.new(); # The time it takes to move one cell
@onready var breathing_timer: Timer = Timer.new(); # The time it takes between breaths

func _ready() -> void:
	init_timers();
	randomize_travel_distance();
	start_breathing();
	hitscan.bullet_hit.connect(is_hit_by_bullet); # Connect signal to check if player has shot at monster
	pass;
	
func _process(delta: float):
	# HACK: Replace this with a proper button bro
	if(Input.is_action_just_pressed("shoot")):
		start_moving();

func init_timers() -> void:
	init_path_travel_timer();
	init_footstep_timer();
	init_travel_delay_timer();

func start_moving() -> void:
	footstep_timer.start();
	path_travel_timer.start();
	play_footstep_sound_raw(); # Play initial footstep sound before starting to move
	
	find_and_travel_on_path();

func stop_moving() -> void:
	footstep_timer.stop();
	path_travel_timer.stop();
	play_footstep_sound_raw(); # Play final footstep sound before stopping movement
	
	travel_delay_timer.start();
	travel_delay_timer.wait_time = randi_range(5, 10);
	
	randomize_footstep_delay();
	randomize_travel_distance();
	
func start_breathing() -> void:
	init_breathing_timer();
	breathing_timer.start();

func init_path_travel_timer() -> void:
	path_travel_timer.wait_time = 1;
	add_child(path_travel_timer);
	path_travel_timer.timeout.connect(find_and_travel_on_path);
	
func init_footstep_timer() -> void:
	randomize_footstep_delay();
	add_child(footstep_timer);
	footstep_timer.timeout.connect(play_footstep_sound);
	
func init_breathing_timer() -> void:
	breathing_timer.wait_time = 3;
	add_child(breathing_timer);
	breathing_timer.timeout.connect(play_breathing_sound);
	
func init_travel_delay_timer() -> void:
	add_child(travel_delay_timer);
	travel_delay_timer.timeout.connect(start_moving);

func find_and_travel_on_path() -> void:
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
			if(travel_distance_in_cells == 0):
				stop_moving();
			else:
				travel_distance_in_cells -= 1;
			print("Travel Distance remaining: ", travel_distance_in_cells);
			print("Monster Coords: ", Vector2(path[path_index].x, path[path_index].y));

func is_hit_by_bullet(collider: Object) -> void:
	if(collider == self):
		# Handle monster hurt
		play_hurt_sound();
		footstep_timer.stop();
		path_travel_timer.stop();
		breathing_timer.stop();

# Randomize travel distance (in cells)
func randomize_travel_distance() -> void:
	travel_distance_in_cells = randi_range(1, 10);
	
func randomize_footstep_delay() -> void:
	var randomized_delay: float = randf_range(0.2, 1.0);
	# Match the path travel time with the footstep time
	path_travel_timer.wait_time = randomized_delay; 
	footstep_timer.wait_time = randomized_delay;
	
func play_footstep_sound() -> void:
	footstep_timer.start();
	travel_delay_timer.stop();
	
	footstep_distant.play();
	footstep_close.play();
	
# Play footstep sounds without starting the footstep timer or travel delay timer
func play_footstep_sound_raw() -> void:
	footstep_distant.play();
	footstep_close.play();

func play_breathing_sound() -> void:
	breathing.play();

func play_hurt_sound() -> void:
	hurt.play();
	
