# Player.gd
# Author: Jamie Rossiter
# Last Updated: 20/04/24
# Handles all data and logic for the Player

class_name Player extends CharacterBody3D

@export var original_position: Vector3 = Vector3(2, 0.5, -1);
var ammo: int = 1; # TESTING: Temp ammo variable. Will be represented as an item.

func _ready() -> void:
	_connect_signals();

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
