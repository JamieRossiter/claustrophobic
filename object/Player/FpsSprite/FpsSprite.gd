class_name FpsSprite extends AnimatedSprite3D

@onready var gunshot_sfx: AudioStreamPlayer3D = $Sfx_Gunshot;
@onready var tinnitus_sfx: AudioStreamPlayer3D = $Sfx_Tinnitus;
@onready var camera: PlayerCamera = get_parent();
@onready var original_shake_pos: Vector2 = Vector2(camera.h_offset, camera.v_offset);

var is_shaking: bool = false;
var elapsed_shake_time: float = 0.0;
var shake_power: float = 5.0;
var shake_time: float = 0.10;

var is_tinnitus: bool = false;
var tinnitus_delay: float = 1.0;
var elapsed_tinnitus_delay: float = 0.0;
var has_tinnitus_deactivated: bool = false;

func _process(delta: float) -> void:
	
	if(Input.is_action_just_pressed("shoot") and !is_playing()):
		handle_shoot();

	if(is_shaking):
		shake_camera(delta);
	
	if(is_tinnitus):
		activate_tinnitus(delta);
		has_tinnitus_deactivated = false;
	
	if(!is_tinnitus and !tinnitus_sfx.playing and !has_tinnitus_deactivated):
		has_tinnitus_deactivated = true;
		AudioServer.set_bus_effect_enabled(AudioServer.get_bus_index("SFX"), 0, false); # Deactivate low pass filter

func handle_shoot() -> void:
	# Activate tinnitus after gunshot
	if(!is_tinnitus and !tinnitus_sfx.playing):
		is_tinnitus = true;
	is_shaking = true; 
	gunshot_sfx.play();
	play_shoot_animation();


func play_shoot_animation() -> void:
	animation = "shoot";
	frame = 0;
	play();

func shake_camera(delta: float) -> void:
	if(elapsed_shake_time < shake_time):
		camera.h_offset = randf_range((-1.0 / 100), (1.0 / 100)) * shake_power;
		camera.v_offset = randf_range((-1.0 / 100), (1.0 / 100)) * shake_power;
		elapsed_shake_time += delta;
	else:
		is_shaking = false;
		elapsed_shake_time = 0;
		camera.h_offset = original_shake_pos.x;
		camera.v_offset = original_shake_pos.y;
		
func activate_tinnitus(delta: float) -> void:
	if(elapsed_tinnitus_delay < tinnitus_delay):
		elapsed_tinnitus_delay += delta;
		return;
	else:
		tinnitus_sfx.play();
		AudioServer.set_bus_effect_enabled(AudioServer.get_bus_index("SFX"), 0, true); # Activate low pass filter
		elapsed_tinnitus_delay = 0;
		is_tinnitus = false;
