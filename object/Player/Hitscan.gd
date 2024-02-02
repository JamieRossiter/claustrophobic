class_name Hitscan extends Node3D

@onready var parent: PlayerCamera = get_parent();
const RAY_RANGE: int = 2000;
signal bullet_hit(collider: Object);

func _input(event: InputEvent) -> void:
	if(event.is_action_pressed("aim") and event.is_action_pressed("shoot")):
		get_camera_collision();

func get_camera_collision()-> void:
	# Get screen point
	var centre: Vector2 = parent.get_viewport().get_size() / 2;
	# Create rays
	var ray_origin: Vector3 = parent.project_ray_origin(centre);
	var ray_end: Vector3 = ray_origin + parent.project_ray_normal(centre) * RAY_RANGE;
	# Create intersections
	var new_intersection: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(ray_origin, ray_end);
	var intersection: Dictionary = parent.get_world_3d().direct_space_state.intersect_ray(new_intersection);
	# Check for intersection
	if(intersection.is_empty()):
		print("no hit");
	else:
		bullet_hit.emit(intersection.collider);
