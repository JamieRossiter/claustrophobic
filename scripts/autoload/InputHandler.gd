# InputHandler.gd
extends Node
	
func _physics_process(_delta: float) -> void:
	# DEBUG Toggle cursor
	if(Input.is_action_just_pressed("ui_cancel")):
		Signals.DEBUG_toggle_cursor.emit();
	
	# Try shoot
	_emit_try_shoot_input();

	# Try lowering
	_emit_lower_input();

	# Aim
	if(Input.is_action_pressed("aim")):
		Signals.player_aim.emit();

	# Try reload
	_emit_try_reload_input();

# TODO: If player successfully hits enemy after shooting, show brief animation of enemy being hit then turn flashlight off. Then turn it back on, the enemy disappeared.
func _emit_try_shoot_input() -> void:
	var is_shooting = Input.is_action_just_pressed("shoot");
	var is_aiming = Input.is_action_pressed("aim");
	if(is_shooting and is_aiming):
		Signals.player_try_shoot.emit();

func _emit_lower_input() -> void:
	var is_lowering = Input.is_action_just_released("aim");
	if(is_lowering):
		Signals.player_try_lower.emit();

func _emit_try_reload_input() -> void:
	var is_reloading: bool = Input.is_action_just_pressed("reload");
	var is_aiming: bool = Input.is_action_pressed("aim");
	if(is_reloading and is_aiming):
		Signals.player_try_reload.emit();
