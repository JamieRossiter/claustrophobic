extends Node
	
func _physics_process(_delta: float) -> void:
	# Movement 
	_emit_movement_input();

	# Try shoot
	_emit_try_shoot_input();

	# Try lowering
	_emit_lower_input();

	# Aim
	if(Input.is_action_pressed("aim")):
		Signals.player_aim.emit();

	# Try reload
	_emit_try_reload_input();

func _emit_try_shoot_input() -> void:
	var is_shooting = Input.is_action_just_pressed("shoot");
	var is_aiming = Input.is_action_pressed("aim");
	if(is_shooting and is_aiming):
		Signals.player_try_shoot.emit();

func _emit_movement_input() -> void:
	
	# Check is moving
	var is_moving: bool = (
		Input.is_action_pressed("move_south") or 
		Input.is_action_pressed("move_north") or
		Input.is_action_pressed("move_east") or
		Input.is_action_pressed("move_west")
	);

	# Check if aiming
	var is_aiming: bool = Input.is_action_pressed("aim"); 

	# Emit signal if moving and not aiming
	if(is_moving and not is_aiming):
		Signals.player_move.emit();    

func _emit_lower_input() -> void:
	var is_lowering = Input.is_action_just_released("aim");
	if(is_lowering):
		Signals.player_try_lower.emit();

func _emit_try_reload_input() -> void:
	var is_reloading: bool = Input.is_action_just_pressed("reload");
	var is_aiming: bool = Input.is_action_pressed("aim");
	if(is_reloading and is_aiming):
		Signals.player_try_reload.emit();
