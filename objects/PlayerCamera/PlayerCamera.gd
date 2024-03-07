"""
PlayerCamera.gd
Handles all logic involving the Player Camera3D instance.
Author: Jamie Rossiter
"""
class_name PlayerCamera extends Camera3D

@onready var player: Player = get_parent();
@onready var flashlight: SpotLight3D = $Flashlight;
const LOOK_SENSITIVITY: float = 5.0;

func _input(event: InputEvent) -> void:
	if(event is InputEventMouseMotion):
		rotation.y = rotation.y - (event.relative.x / 1000) * LOOK_SENSITIVITY;	
		if(flashlight.is_visible_in_tree()):
			rotation.x = clamp(rotation.x - (event.relative.y / 1000) * LOOK_SENSITIVITY, -1.5, 1.5);
		else:
			rotation.x = 25;
