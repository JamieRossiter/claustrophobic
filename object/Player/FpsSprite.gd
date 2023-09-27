class_name FpsSprite extends AnimatedSprite3D

func _process(delta: float) -> void:
	if(Input.is_action_just_pressed("shoot")):
		animation = "shoot";
		play();
	if(frame == 4):
		animation = "idle";
		frame = 0;
		
func _input(event: InputEvent) -> void:
	if(Input.is_action_just_pressed("reload")):
		animation = "reload_empty";
		frame = 0;
