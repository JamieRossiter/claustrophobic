class_name PlayerCamera extends Camera3D

const LOOK_SENSITIVITY: float = 5.0;
@onready var player: Player = get_parent();

func _process(delta: float):
	if(Input.is_action_just_pressed("ui_cancel")):
		if(Input.mouse_mode == Input.MOUSE_MODE_VISIBLE):
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE;

func _input(event: InputEvent):
	if(event is InputEventMouseMotion):
		player.rotate_y(-event.relative.x * (LOOK_SENSITIVITY / 1000));
		rotate_x(-event.relative.y * (LOOK_SENSITIVITY / 1000));
		rotation = Vector3(clamp(rotation.x, -PI/2, PI/2), rotation.y, rotation.z);
