class_name PlayerCamera extends Camera3D

const LOOK_SENSITIVITY: float = 5.0;
@onready var player: Player = get_parent();
@onready var is_bobbling: bool = false;

func _process(delta: float) -> void:
	
	# Handle camera bobble
	if(player.is_moving()):
		if(not is_bobbling):
			is_bobbling = true;
			bobble_up();
	else:
		is_bobbling = false;
		bobble_down();
	
	# Handle remove cursor
	if(Input.is_action_just_pressed("ui_cancel")):
		if(Input.mouse_mode == Input.MOUSE_MODE_VISIBLE):
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE;

func _input(event: InputEvent) -> void:
	if(event is InputEventMouseMotion):
		player.rotate_y(-event.relative.x * (LOOK_SENSITIVITY / 1000));
		rotate_x(-event.relative.y * (LOOK_SENSITIVITY / 1000));
		rotation = Vector3(clamp(rotation.x, -PI/2, PI/2), rotation.y, rotation.z);

func bobble_up() -> void:
	var bobble_up_tween: Tween = get_tree().create_tween();
	bobble_up_tween.tween_property(self, "v_offset", 0.03, 0.5);
	bobble_up_tween.connect("finished", bobble_down);

func bobble_down() -> void:
	var bobble_down_tween: Tween = get_tree().create_tween();
	bobble_down_tween.tween_property(self, "v_offset", 0, 0.5);
	
	if(is_bobbling):
		bobble_down_tween.connect("finished", bobble_up);
	else:
		if(bobble_down_tween.is_connected("finished", bobble_up)):
			bobble_down_tween.disconnect("finished", bobble_up);
