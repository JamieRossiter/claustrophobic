# Player.gd
class_name Player extends CharacterBody3D

@onready var original_position: Vector3 = self.position;
var ammo: int = 3; # TODO: Temp ammo variable. Will be represented as an item.
var direction: Enums.Direction;

func _ready() -> void:
	self._connect_signals();

func _physics_process(delta: float):
	self._determine_direction();

func _connect_signals() -> void:
	Signals.player_try_shoot.connect(_handle_try_shoot); # Shoot
	Signals.player_try_reload.connect(_handle_try_reload); # Reload

func _handle_try_shoot() -> void: 

	# No ammo, dry fire
	if(ammo <= 0):
		Signals.player_dry_fire.emit();
		print("Dry fire");
		return;

	# Shoot
	Signals.player_shoot.emit(ammo);
	ammo -= 1;
	print("Shoot");

func _handle_try_reload() -> void:

	# If ammo, no reload
	if(ammo > 0): return; 
	
	# Reload
	Signals.player_reload.emit();
	print("Reload");


func _determine_direction() -> void:
	var rounded_x = round(global_transform.basis.x.x)
	var rounded_z = round(global_transform.basis.x.z);
	# Determine direction
	if(rounded_x == 0 and rounded_z == 1):
		direction = Enums.Direction.NORTH;
	elif(rounded_x == -1 and rounded_z == 0):
		direction = Enums.Direction.WEST;
	elif(rounded_x == 0 and rounded_z == -1):
		direction = Enums.Direction.SOUTH;
	elif(rounded_x == 1 and rounded_z == 0):
		direction = Enums.Direction.EAST;
