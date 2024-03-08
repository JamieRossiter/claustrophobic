"""
PlayerAnimation.gd
Handles all logic involving player animations.
Author: Jamie Rossiter
"""
class_name PlayerAnimation extends Node3D

# Constants
const TARGET_Y_POS: float = -0.050;
@onready var INITIAL_Y_POS: float = self.position.y;

# Onready variables
@onready var player: Player = get_parent().get_parent();
@onready var camera: Camera3D = get_parent();
@onready var muzzle_flash: OmniLight3D = $Sketchfab_model/pistolanim_fbx/Object_2/RootNode/Armature/Object_5/Skeleton3D/Object_51/MuzzleFlash;

# Shake data - for player and screen shaking
class ShakeData:
	var subject: Node = null;
	var is_shaking: bool;
	var elapsed_shake_time: float;
	var shake_time: float = 10;
	var shake_power: float;
	var original_shake_pos: Vector3;
	func _init(
		sub: Node, 
		shaking: bool, 
		elapsed_time: float, 
		time: float, 
		power: float, 
		original_pos: Vector3
	) -> void:
			subject = sub;
			is_shaking = shaking;
			elapsed_shake_time = elapsed_time;
			shake_time = time;
			shake_power = power;
			original_shake_pos = original_pos;
var gun_shake_data: ShakeData = ShakeData.new(self, false, 0.0, 1.0, 0.3, self.rotation);
@onready var camera_shake_data: ShakeData = ShakeData.new(camera, false, 0.0, 0.10, 0.8, camera.position);
		
# Animation
@onready var anim: AnimationPlayer = $AnimationPlayer;
@onready var is_animation_reloading: bool;
@onready var is_animation_shooting: bool;

func _ready() -> void:
	init_anim();
	player.shoot.connect(shoot); # Connect shoot signal
	player.reload.connect(reload) # Connect reload signal

func _process(delta: float) -> void:
	init_animation_ranges();
	handle_aim();
	handle_shake_gun(gun_shake_data);
	if(camera_shake_data.is_shaking):
		handle_shake_camera(camera_shake_data, delta)
	handle_animation_pause();
	print(str(snapped(anim.current_animation_position, 0.1)));
	
	# Test anim
	if(anim_at_position(7.7) or anim_at_position(11.5)):
		muzzle_flash.omni_range = 0;

func init_animation_ranges() -> void:
	is_animation_reloading = anim_in_range(12.1, 15.9);
	is_animation_shooting = anim_in_range(7.5, 8.0);

# Handles the pausing of player animations for aiming or shooting
func handle_animation_pause() -> void:
	if(anim_at_position(11.9)): # For shooting with no ammo remaining
		anim.seek(11.9);
	elif(
		anim_at_position(8.0) or # For shooting with ammo remaining
		anim_at_position(16.0) # For end of reload animation
	): 
		anim.seek(8.0); # Seek to default animation
	else:
		return;
	anim.pause();
	

# Is the current animation position within a range
func anim_in_range(start_pos: float, end_pos: float) -> bool:
	return snapped(anim.current_animation_position, 0.1) > start_pos and snapped(anim.current_animation_position, 0.1) < end_pos;

# Is the current animation position at a particular position
func anim_at_position(pos: float) -> bool:
	return str(snapped(anim.current_animation_position, 0.1)) == str(snapped(pos, 0.1));

func init_anim() -> void:
	lower();
	anim.play("Scene");
	anim.advance(8.0); # Advance to default animation

func handle_aim() -> void:
	if(Input.is_action_just_pressed("aim")):
		aim();
	elif(not Input.is_action_pressed("aim") and not is_animation_reloading):
		lower();
			
func handle_shake_gun(shake_data: ShakeData) -> void:
	if(shake_data.is_shaking):
		var offset = randf_range((-0.01), (0.01)) * shake_data.shake_power;
		self.rotation = shake_data.original_shake_pos + Vector3(offset, offset, 0);
		
func handle_shake_camera(shake_data: ShakeData, delta: float) -> void:
		# If still shaking
		if(shake_data.elapsed_shake_time < shake_data.shake_time):
			if(shake_data.subject is PlayerCamera):
				camera.h_offset = randf_range((-1.0 / 100), (1.0 / 100)) * shake_data.shake_power;
				camera.v_offset = randf_range((-1.0 / 100), (1.0 / 100)) * shake_data.shake_power;
				shake_data.elapsed_shake_time += delta;
		else:
			# If stopped shaking
			shake_data.is_shaking = false;
			shake_data.elapsed_shake_time = 0;
			if(shake_data.subject is PlayerCamera):
					camera.h_offset = 0;
					camera.v_offset = 0;
					
func aim() -> void:
	var aim_tween: Tween = create_tween();
	aim_tween.tween_property(self, "position:y", TARGET_Y_POS, 0.5);
	gun_shake_data.is_shaking = true;
	
func lower() -> void:
	var lower_tween: Tween = create_tween();
	lower_tween.tween_property(self, "position:y", INITIAL_Y_POS, 0.5);
	gun_shake_data.is_shaking = false;
	# Revert to original rotation after gun shaking
	var original_position_tween: Tween = create_tween();
	original_position_tween.tween_property(self, "rotation", gun_shake_data.original_shake_pos, 0.5);

func shoot(ammo: int) -> void:	
	anim.play("Scene");
	
	# Check ammo to determine animation
	if(ammo <= 1):
		anim.seek(11.4); # No ammo remaining
	else:
		anim.seek(7.6); # Ammo remaining
		
	# Activate muzzle flash
	muzzle_flash.omni_range = 1;
	# Camera shake
	camera_shake_data.is_shaking = true; 
	
func reload() -> void:
	anim.play("Scene");
	anim.seek(12.0, true);
		


			
