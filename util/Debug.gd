class_name Debug extends Node

@onready var fps_counter: FPSCounter = $FPSCounter;
@onready var start_monster_move_button: Button = $StartMonsterMove;
@onready var toggle_aggro_button: Button = $ToggleAggro;
var is_showing: bool = false;

func _ready() -> void:
	hide_all();

func _process(delta: float) -> void:
	if(Input.is_action_just_pressed("debug")):
		if(is_showing):
			hide_all();
		else:
			show_all()
		is_showing = not is_showing;
		
func hide_all() -> void:
	fps_counter.hide();
	start_monster_move_button.hide();
	toggle_aggro_button.hide();

func show_all() -> void:
	fps_counter.show();
	start_monster_move_button.show();
	toggle_aggro_button.show();
