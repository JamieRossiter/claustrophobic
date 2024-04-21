# Camera.gd
# Author: Jamie Rossiter
# Last Updated: 21/04/24
# Handles camera data and logic
class_name Camera extends Camera3D

@export var LOOK_SENSITIVITY: float = 5.0;
var direction: Enums.Direction;

func _physics_process(_delta: float) -> void:
	_determine_camera_direction();

func _input(event: InputEvent) -> void:
	
	# Rotation
	if(event is InputEventMouseMotion):
		rotation.y = rotation.y - (event.relative.x / 1000) * LOOK_SENSITIVITY;
		rotation.x = clamp(rotation.x - (event.relative.y / 1000) * LOOK_SENSITIVITY, -1.5, 1.5);

func _determine_camera_direction() -> void:

	# Round camera x and z values to nearest whole number
	var rounded_camera_x = round(global_transform.basis.x.x)
	var rounded_camera_z = round(global_transform.basis.x.z);

	# Determine direction
	if(rounded_camera_x == 0 and rounded_camera_z == 1):
		direction = Enums.Direction.NORTH;
	elif(rounded_camera_x == -1 and rounded_camera_z == 0):
		direction = Enums.Direction.WEST;
	elif(rounded_camera_x == 0 and rounded_camera_z == -1):
		direction = Enums.Direction.SOUTH;
	elif(rounded_camera_x == 1 and rounded_camera_z == 0):
		direction = Enums.Direction.EAST;