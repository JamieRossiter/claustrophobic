class_name MinimapCameraRT extends RemoteTransform3D

func _input(event: InputEvent) -> void:
	# Handle y axis rotation
	if(event is InputEventMouseMotion):
		rotation.y = rotation.y - (event.relative.x / 1000) * Globals.CAMERA_LOOK_SENSITIVITY.y;	
