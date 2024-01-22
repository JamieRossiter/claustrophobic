class_name CustomDebug extends Node

@onready var fps_counter: FPSCounter = $FPSCounter;
@onready var start_monster_move_button: Button = $StartMonsterMove;
@onready var toggle_aggro_button: Button = $ToggleAggro;
var active: bool = false;

func _ready() -> void:
	hide_all();

func _process(delta: float) -> void:
	if(Input.is_action_just_pressed("debug")):
		if(active):
			hide_all();
		else:
			show_all()
		toggle_debug();

func toggle_debug() -> void:
	active = not active;		

func hide_all() -> void:
	fps_counter.hide();
	start_monster_move_button.hide();
	toggle_aggro_button.hide();

func show_all() -> void:
	fps_counter.show();
	start_monster_move_button.show();
	toggle_aggro_button.show();
