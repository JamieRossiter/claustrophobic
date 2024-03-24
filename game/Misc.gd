class_name Debug extends Node3D

var is_debug: bool = true;
@onready var enemy_state_menu: MenuButton = $EnemyStateMenu;

signal state_change(state: Enums.EnemyState);

func _ready() -> void:
	enemy_state_menu.get_popup().id_pressed.connect(handle_state_change);

func _process(delta: float) -> void:
	handle_debug_toggle();

# Remove the cursor when pressing the "ESC" button
func handle_debug_toggle() -> void:
	if(Input.is_action_just_pressed("ui_cancel")):
		toggle_cursor();
		toggle_debug_menu();
		is_debug = not is_debug;

func handle_state_change(menu_id: int) -> void:
	match(menu_id):
		0: # Idle
			state_change.emit(Enums.EnemyState.IDLE);
		1: # Aggro
			state_change.emit(Enums.EnemyState.AGGRO);
		2: # Roaming
			state_change.emit(Enums.EnemyState.ROAMING);
		3: # Jumpscare
			state_change.emit(Enums.EnemyState.JUMPSCARE);
		
func toggle_cursor() -> void:
	if(Input.mouse_mode == Input.MOUSE_MODE_VISIBLE):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE;
	
func toggle_debug_menu() -> void:
	toggle_enemy_state_menu();
	
func toggle_enemy_state_menu() -> void:
	if(enemy_state_menu.is_visible_in_tree()):
		enemy_state_menu.hide();
	else:
		enemy_state_menu.show();
