class_name MainMenu extends Node

@onready var start_game_button: Button = $VBoxContainer/StartGameButton;
@onready var menu_background: ColorRect = $MenuBackground;
@onready var menu_title: Label = $VBoxContainer/MenuTitle;

func _on_start_game_button_pressed():
	hide_all_menu_elements();

func hide_all_menu_elements() -> void:
	start_game_button.hide();
	menu_background.hide();
	menu_title.hide();
