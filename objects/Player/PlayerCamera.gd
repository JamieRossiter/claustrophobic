"""
PlayerCamera.gd
Handles all logic involving the Player Camera3D instance.
Author: Jamie Rossiter
"""
class_name PlayerCamera extends Camera3D

@onready var player: Player = get_parent();
@onready var flashlight: SpotLight3D = $PlayerFlashlight;
@onready var is_bobbling: bool = false;
const LOOK_SENSITIVITY: float = 5.0;

func _process(delta: float) -> void:
	handle_camera_bobble();

func _input(event: InputEvent) -> void:
	handle_camera_rotation(event)

func handle_camera_rotation(event: InputEvent) -> void:
	if(event is InputEventMouseMotion):
		rotation.y = rotation.y - (event.relative.x / 1000) * LOOK_SENSITIVITY;	
		if(flashlight.is_visible_in_tree()):
			rotation.x = clamp(rotation.x - (event.relative.y / 1000) * LOOK_SENSITIVITY, -1.5, 1.5);
		else:
			rotation.x = 25;

func handle_camera_bobble() -> void:
	# Handle camera bobble
	if(player.is_moving() and not player.is_aiming()):
		if(not is_bobbling):
			is_bobbling = true;
			bobble_up();
	else:
		is_bobbling = false;
		bobble_down();

func bobble_up() -> void:
	var bobble_up_tween: Tween = get_tree().create_tween();
	bobble_up_tween.tween_property(self, "v_offset", 0.03, 0.7);
	bobble_up_tween.connect("finished", bobble_down);

func bobble_down() -> void:
	var bobble_down_tween: Tween = get_tree().create_tween();
	bobble_down_tween.tween_property(self, "v_offset", 0, 0.7);
	
	if(is_bobbling):
		bobble_down_tween.connect("finished", bobble_up);
	else:
		if(bobble_down_tween.is_connected("finished", bobble_up)):
			bobble_down_tween.disconnect("finished", bobble_up);
