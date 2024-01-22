class_name SplashScreen extends ColorRect

@onready var intro_label: Label = $IntroLabel;
@onready var gameover_label: Label = $GameOverLabel;

func show_intro_screen() -> void:
	self_modulate = Color.BLACK;
	intro_label.self_modulate = Color.WHITE;
	hide_all_labels_except(intro_label);
	show();
	var fade_tween: Tween = create_tween();
	fade_tween.tween_property(self, "self_modulate", Color.TRANSPARENT, 3.0);
	fade_tween.tween_property(intro_label, "self_modulate", Color.TRANSPARENT, 0.5);

func show_gameover_screen() -> void:
	self_modulate = Color.TRANSPARENT;
	gameover_label.self_modulate = Color.TRANSPARENT;
	hide_all_labels_except(gameover_label);
	show();
	var fade_tween: Tween = create_tween();
	fade_tween.tween_property(self, "self_modulate", Color.BLACK, 1.0);
	fade_tween.tween_property(gameover_label, "self_modulate", Color.WHITE, 0.5);
	

func hide_all_labels_except(label: Label) -> void:
	intro_label.hide();
	gameover_label.hide();
	label.show(); # Show the selected label after hiding
