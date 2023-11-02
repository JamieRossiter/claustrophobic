class_name HUDLayer extends CanvasLayer

@onready var PlayerCamera: Camera3D = get_parent().get_node("PlayerCamera");
@onready var GunCamera: Camera3D = $SubViewportContainer/GunSubViewport/GunCamera;

func _process(delta: float):
	GunCamera.global_transform = PlayerCamera.global_transform;
