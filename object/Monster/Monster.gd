class_name Monster extends CharacterBody3D

const SPEED: float = 2.0;

var path_index: int = 0;
var path: Array[Vector2i];
var travel_distance_in_cells: int = -1;
var is_aggro: bool = false; # Indicates that the monster is deliberately seeking out the player
var is_stunned: bool = false;

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
@onready var stun_timer: Timer = Timer.new(); # The time it takes for the monster to wake up from a stun

func _ready() -> void:
	init_timers();
	randomize_travel_distance();
	init_breathing_timer();
	hitscan.bullet_hit.connect(is_hit_by_bullet); # Connect signal to check if player has shot at monster
	
func _process(delta: float) -> void:
	# If the monster is in the player's vicinity, trigger a game over
	if(is_in_player_vicinity() and not is_stunned and is_aggro):
		parent.handle_game_over();

func toggle_aggro(activate = null) -> void:
	if(activate):
		is_aggro = activate;
	else:
		is_aggro = not is_aggro;
	pathfinder.set_target(); # Change target based on aggro state
	if(is_aggro): # if aggro, hard set footstep delay to running speed and ignore travel delay
		set_footstep_delay(0.3);
	else:
		randomize_footstep_delay();
	
func init_timers() -> void:
	init_path_travel_timer();
	init_footstep_timer();
	init_travel_delay_timer();
	init_stun_timer();

func start_moving() -> void:
	footstep_timer.start();
	path_travel_timer.start();
	breathing_timer.start();
	play_footstep_sound_raw(); # Play initial footstep sound before starting to move
	find_and_travel_on_path();
	if(is_aggro):
		set_footstep_delay(0.3);
	else:
		randomize_footstep_delay();
	is_stunned = false;

func stop_moving() -> void:
	footstep_timer.stop();
	path_travel_timer.stop();
	play_footstep_sound_raw(); # Play final footstep sound before stopping movement	
	travel_delay_timer.wait_time = randi_range(5, 10); # Ignored if aggro
	travel_delay_timer.start();
	randomize_travel_distance(); # Ignored if aggro

func stop() -> void:
	footstep_timer.stop();
	path_travel_timer.stop();
	travel_delay_timer.stop();
	breathing_timer.stop();

func stun() -> void:
	stop();
	is_stunned = true;
	stun_timer.start();
	play_footstep_sound_raw(); # Play final footstep sound before stopping movement	
	
func init_path_travel_timer() -> void:
	path_travel_timer.wait_time = 1;
	add_child(path_travel_timer);
	path_travel_timer.timeout.connect(find_and_travel_on_path);
	
func init_footstep_timer() -> void:
	if(is_aggro): # if aggro, hard set footstep delay to running speed
		set_footstep_delay(0.3);
	else:
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
	travel_delay_timer.start();
	
func init_stun_timer() -> void:
	stun_timer.wait_time = 30;
	add_child(stun_timer);
	stun_timer.timeout.connect(start_moving); 

func find_and_travel_on_path() -> void:
	if(not path):
		pathfinder.set_target(); # Resets the target if the path is invalid
		path = pathfinder.get_astar_path();
		print("Path: ", path); 
	else:
		if(path_index >= path.size() - 1):
			path_index = 0;
			pathfinder.set_target(); # Reset the target, this re-randomizes a target if not aggro
			path = pathfinder.get_astar_path();
			print("Path: ", path); 
		else:
			path_index += 1;
		if(path.size() > 0):
			# Change monster position
			position.x = path[path_index].x * 0.6;
			position.z = path[path_index].y * 0.6;
				
			if(travel_distance_in_cells == 0):
				if(not is_aggro): # if aggro, ignore cell travel distance
					stop_moving();
			else:
				travel_distance_in_cells -= 1;
			print("Travel Distance remaining: ", travel_distance_in_cells);
			print("Monster Path Pos: ", Vector2(path[path_index].x, path[path_index].y));
			print("Monster True Coords: ", Vector2(position.x, position.z));

# Check vicinity by comparing monster position to closest valid vent cell position to player
func is_in_player_vicinity() -> bool:
	var in_x_vicinity: bool = position.x == parent.get_closest_vent_cell_position_to_position(parent.player.position).x;
	var in_z_vicinity: bool = position.z == parent.get_closest_vent_cell_position_to_position(parent.player.position).z;
	return in_x_vicinity and in_z_vicinity;

func is_hit_by_bullet(collider: Object) -> void:
	if(collider == self and not is_stunned):
		# Handle monster hurt
		play_hurt_sound();
		stun();
	else:
		toggle_aggro(true); # If the shot has missed, trigger monster aggro

# Randomize travel distance (in cells)
func randomize_travel_distance() -> void:
	travel_distance_in_cells = randi_range(1, 10);

func set_footstep_delay(delay: float) -> void:
	path_travel_timer.wait_time = delay;
	footstep_timer.wait_time = delay;

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
	
# TESTING: Aggro toggle button
func _on_toggle_aggro_toggled(button_pressed: bool) -> void:
	toggle_aggro();
	print("Aggro is ", is_aggro);

# TESTING: Monster start move button
func _on_start_monster_move_pressed():
	start_moving();
	
