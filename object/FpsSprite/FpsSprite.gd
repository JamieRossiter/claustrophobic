class_name FpsSprite extends AnimatedSprite3D

const INITIAL_POS: float = -0.21;
const TARGET_POS: float = -0.06;

@onready var gunshot_sfx: AudioStreamPlayer3D = $Sfx_Gunshot;
@onready var dry_sfx: AudioStreamPlayer3D = $Sfx_Dry;
@onready var tinnitus_sfx: AudioStreamPlayer3D = $Sfx_Tinnitus;
@onready var pump_sfx: AudioStreamPlayer3D = $Sfx_Pump;

@onready var camera_shake_data: ShakeData = ShakeData.new(get_parent(), false, 0.0, 0.10, 5.0, Vector2(get_parent().position.x, get_parent().position.y));
@onready var gun_shake_data: ShakeData = ShakeData.new(self, false, 0.0, 1.0, 0.8, Vector2(self.position.x, self.position.y));

@onready var player: Player = get_parent().get_parent();
@onready var muzzle_flash: OmniLight3D = $MuzzleFlash;

var has_tinnitus_deactivated: bool = false;
var low_pass_filter: AudioEffectLowPassFilter = AudioServer.get_bus_effect(AudioServer.get_bus_index("SFX"), 0);

func _ready() -> void:
	self.position.y = INITIAL_POS;
	muzzle_flash.omni_range = 0;
	pass;

func _process(delta: float) -> void:
	
	# Handle aim
	if(Input.is_action_just_pressed("aim")):
		handle_aim();
	elif(Input.is_action_just_released("aim")):
		handle_lower();
	
	# Handle shooting
	if(Input.is_action_just_pressed("shoot") and Input.is_action_pressed("aim") and !is_playing()):
		if(player.ammo > 0):
			handle_shoot();
		else:
			if(not dry_sfx.playing):
				handle_dry();
		
	# Handle shooting finished
	if(animation == "shoot"):
		if(frame == 8):
			handle_shoot_finish(); # Handle shoot finish
		elif(frame == 2):
			muzzle_flash.omni_range = 0; # Handle muzzle end	

	# Handle camera shake
	if(camera_shake_data.is_shaking):
		perform_shake(camera_shake_data, delta);
		pass;
	
	# Handle gun shake
	if(gun_shake_data.is_shaking):
		perform_shake(gun_shake_data, delta);
		pass;
	
	# Handle tinnitus
	if(!tinnitus_sfx.playing and !has_tinnitus_deactivated):
		has_tinnitus_deactivated = true;
		deactivate_tinnitus();

func handle_aim() -> void:
	player.is_aiming = true;
	play_aim_animation();
	var aim_tween: Tween = create_tween();
	aim_tween.tween_property(self, "position:y", TARGET_POS, 0.5);
	gun_shake_data.is_shaking = true;
	
func handle_lower() -> void:
	player.is_aiming = false;
	var lower_tween: Tween = create_tween();
	lower_tween.tween_property(self, "position:y", INITIAL_POS, 0.5);
	gun_shake_data.is_shaking = false;

func handle_shoot() -> void:
	camera_shake_data.is_shaking = true; 
	play_shoot_animation();
	if(!tinnitus_sfx.playing):
		activate_tinnitus();

func handle_dry() -> void:
	dry_sfx.play();

func handle_shoot_finish() -> void:
	pump_sfx.play();
	animation = "pump";	
	frame = 0;
	play();

func play_aim_animation() -> void:
	animation = "aim";
	frame = 0;
	play();
		
func play_shoot_animation() -> void:
	gunshot_sfx.play();
	animation = "shoot";
	muzzle_flash.omni_range = 1;
	frame = 0;
	play();

func perform_shake(shake_data: ShakeData, delta: float) -> void:
		# If still shaking
		if(shake_data.elapsed_shake_time < shake_data.shake_time):
			if(shake_data.subject is PlayerCamera):
				start_camera_shake(shake_data.subject, shake_data.shake_power)
				shake_data.elapsed_shake_time += delta; # Only camera shake elapses shake time. 
														# Gun shake is indefinite.
			elif(shake_data.subject == self):
				start_gun_shake(self, shake_data.shake_power);
		else:		
			# If end shaking
			shake_data.is_shaking = false;
			shake_data.elapsed_shake_time = 0;
			if(shake_data.subject is PlayerCamera):
				end_camera_shake(shake_data.subject, shake_data.original_shake_pos);


func start_camera_shake(camera: PlayerCamera, shake_power: float) -> void:
	camera.h_offset = randf_range((-1.0 / 100), (1.0 / 100)) * shake_power;
	camera.v_offset = randf_range((-1.0 / 100), (1.0 / 100)) * shake_power;

func end_camera_shake(camera: PlayerCamera, original_shake_pos: Vector2) -> void:
	camera.h_offset = original_shake_pos.x;
	camera.v_offset = original_shake_pos.y;

func start_gun_shake(gun: FpsSprite, shake_power: float) -> void:
	gun.offset.x = randf_range((-1.0), (1.0)) * shake_power;
	gun.offset.y = randf_range((-1.0), (1.0)) * shake_power;
	
func activate_tinnitus() -> void:
	tinnitus_sfx.play();
	has_tinnitus_deactivated = false;
	var tinnitus_onset_tween: Tween = create_tween();
	tinnitus_onset_tween.tween_property(low_pass_filter, "cutoff_hz", 2000, 2);

func deactivate_tinnitus() -> void:
	var tinnitus_offset_tween: Tween = create_tween();
	tinnitus_offset_tween.tween_property(low_pass_filter, "cutoff_hz", 20400, 0.5);
