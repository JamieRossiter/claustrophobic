class_name Menu extends Node

@onready var menu_background: ColorRect = $MenuBackground;

# Title Screen
@onready var menu_title: Label = $TitleScreenContainer/Title;
@onready var start_game_button: Button = $TitleScreenContainer/StartGameButton;

# Level Start
@onready var level_start_container: VBoxContainer = $LevelStartContainer;
@onready var intro_label: Label = $LevelStartContainer/IntroLabel;

# Game Over
@onready var gameover_label: Label = $LevelStartContainer/GameOverLabel;
@onready var youwon_label: Label = $LevelStartContainer/YouWonLabel;

func show_intro_screen() -> void:
	level_start_container.show();
	menu_background.self_modulate = Color.BLACK;
	intro_label.self_modulate = Color.WHITE;
	hide_all_labels_except(intro_label);
	var fade_tween: Tween = create_tween();
	fade_tween.tween_property(menu_background, "self_modulate", Color.TRANSPARENT, 3.0);
	fade_tween.tween_property(intro_label, "self_modulate", Color.TRANSPARENT, 0.5);

func show_gameover_screen() -> void:
	menu_background.self_modulate = Color.BLACK;
	hide_all_labels_except(gameover_label);

func show_youwon_screen() -> void:
	menu_background.self_modulate = Color.BLACK;
	hide_all_labels_except(youwon_label);
	
func hide_all_labels_except(label: Label) -> void:
	intro_label.hide();
	gameover_label.hide();
	youwon_label.hide();
	label.show(); # Show the selected label after hiding

func _on_start_game_button_pressed():
	hide_all_menu_elements();

func hide_all_menu_elements() -> void:
	start_game_button.hide();
	menu_title.hide();
