# Utils.gd
extends Node

func _ready() -> void:
	self._connect_signals();
	
func _connect_signals() -> void:
	Signals.DEBUG_toggle_cursor.connect(_toggle_cursor);

func _toggle_cursor() -> void:
	if(Input.mouse_mode == Input.MOUSE_MODE_VISIBLE):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE;
