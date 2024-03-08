class_name MinimapLightRT extends RemoteTransform3D

const LOOK_SENSITIVITY: float = 5.0;

func _input(event: InputEvent) -> void:
	if(event is InputEventMouseMotion):
		rotation.y = rotation.y - (event.relative.x / 1000) * LOOK_SENSITIVITY;	
