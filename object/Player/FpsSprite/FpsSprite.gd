class_name FpsSprite extends AnimatedSprite3D

@onready var gunshot_sfx: AudioStreamPlayer3D = $Sfx_Gunshot;
@onready var tinnitus_sfx: AudioStreamPlayer3D = $Sfx_Tinnitus;
@onready var camera: PlayerCamera = get_parent();
@onready var original_shake_pos: Vector2 = Vector2(camera.h_offset, camera.v_offset);

var is_shaking: bool = false;
var elapsed_shake_time: float = 0.0;
var shake_power: float = 5.0;
var shake_time: float = 0.10;

var has_tinnitus_deactivated: bool = false;
var low_pass_filter: AudioEffectLowPassFilter = AudioServer.get_bus_effect(AudioServer.get_bus_index("SFX"), 0)

func _process(delta: float) -> void:
	
	if(Input.is_action_just_pressed("shoot") and !is_playing()):
		handle_shoot();

	if(is_shaking):
		shake_camera(delta);
	
	if(!tinnitus_sfx.playing and !has_tinnitus_deactivated):
		has_tinnitus_deactivated = true;
		deactivate_tinnitus();

func handle_shoot() -> void:
	is_shaking = true; 
	play_shoot_animation();
	if(!tinnitus_sfx.playing):
		activate_tinnitus();


func play_shoot_animation() -> void:
	gunshot_sfx.play();
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
		
func activate_tinnitus() -> void:
	tinnitus_sfx.play();
	has_tinnitus_deactivated = false;
	var tween: Tween = get_tree().create_tween();
	tween.tween_property(low_pass_filter, "cutoff_hz", 2000, 1);

func deactivate_tinnitus() -> void:
	var tween: Tween = get_tree().create_tween();
	tween.tween_property(low_pass_filter, "cutoff_hz", 20400, 0.5);
