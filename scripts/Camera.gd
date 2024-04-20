class_name Camera extends Camera3D

@export var LOOK_SENSITIVITY: float = 5.0;

func _input(event: InputEvent) -> void:
	
	# Rotation
	if(event is InputEventMouseMotion):
		rotation.y = rotation.y - (event.relative.x / 1000) * LOOK_SENSITIVITY;
		rotation.x = clamp(rotation.x - (event.relative.y / 1000) * LOOK_SENSITIVITY, -1.5, 1.5);
