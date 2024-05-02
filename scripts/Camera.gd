class_name Camera extends Camera3D

@onready var original_position: Vector3 = position;
@onready var is_bobbling: bool = false;
@onready var DEFAULT_SHAKE_POWER: float = 0.2;
var direction: Enums.Direction;

# Shake data
var is_shaking: bool = true;
var elapsed_shake_time: float;
var total_shake_time: float;
var shake_power: float = DEFAULT_SHAKE_POWER;

func _ready() -> void:
	self._connect_signals();
	# TODO: Make this a util function
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED; 

func _connect_signals() -> void:
	Signals.player_aim.connect(_nervous_shake);
	Signals.player_shoot.connect(_start_shake.bind(0.15, 8));
	
func _physics_process(delta: float) -> void:
	# Determine the direction character is facing
	self._determine_camera_direction();
	# Handle shake
	if(is_shaking):
		self._shake(delta);

func _input(event: InputEvent) -> void:
	
	# Rotation
	if(event is InputEventMouseMotion):
		rotation.y = rotation.y - (event.relative.x / 1000) * Globals.CAMERA_LOOK_SENSITIVITY.y ;
		rotation.x = clamp(rotation.x - (event.relative.y / 1000) * Globals.CAMERA_LOOK_SENSITIVITY.x, -1.5, 1.5);

func _determine_camera_direction() -> void:

	# Round camera x and z values to nearest whole number
	var rounded_camera_x = round(global_transform.basis.x.x)
	var rounded_camera_z = round(global_transform.basis.x.z);

	# Determine direction
	if(rounded_camera_x == 0 and rounded_camera_z == 1):
		direction = Enums.Direction.NORTH;
	elif(rounded_camera_x == -1 and rounded_camera_z == 0):
		direction = Enums.Direction.WEST;
	elif(rounded_camera_x == 0 and rounded_camera_z == -1):
		direction = Enums.Direction.SOUTH;
	elif(rounded_camera_x == 1 and rounded_camera_z == 0):
		direction = Enums.Direction.EAST;

# Bobble up
func _bobble_up() -> void:
	var bobble_up_tween: Tween = get_tree().create_tween();
	bobble_up_tween.tween_property(self, "v_offset", 0.1, 0.7);
	bobble_up_tween.connect("finished", self._bobble_down);

# Bobble down
func _bobble_down() -> void:
	var bobble_down_tween: Tween = get_tree().create_tween();
	bobble_down_tween.tween_property(self, "v_offset", 0.0, 0.7);
	
	if(is_bobbling):
		bobble_down_tween.connect("finished", self._bobble_up);
	else:
		if(bobble_down_tween.is_connected("finished", self._bobble_up)):
			bobble_down_tween.disconnect("finished", self._bobble_up);

# General subtle nervous shaking of the camera
func _nervous_shake() -> void:
	var offset = randf_range((-0.01), (0.01)) * shake_power;
	h_offset = offset;
	v_offset = offset;

func _start_shake(ammo: int, time: float, power: float) -> void:
	# Continue shaking
	total_shake_time = time;
	shake_power = power;
	elapsed_shake_time = 0;
	is_shaking = true;

# Perform shaking
func _shake(delta: float) -> void:
	if((elapsed_shake_time < total_shake_time) and is_shaking):
		h_offset = randf_range((-1.0 / 100), (1.0 / 100)) * shake_power;
		v_offset = randf_range((-1.0 / 100), (1.0 / 100)) * shake_power;
		elapsed_shake_time += delta;
		print(elapsed_shake_time);
	else:
		self._stop_shake();

func _stop_shake() -> void:
	is_shaking = false;
	elapsed_shake_time = 0;
	total_shake_time = 0;
	shake_power = DEFAULT_SHAKE_POWER;
	h_offset = 0;
	v_offset = 0;

# Initiate bobble
func start_bobble() -> void:
	if(not is_bobbling):
		is_bobbling = true;
		self._bobble_up();

# Stop bobbling
func end_bobble() -> void:
	is_bobbling = false;
	self._bobble_down();
		
