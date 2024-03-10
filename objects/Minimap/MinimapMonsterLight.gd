class_name MinimapMonsterLight extends OmniLight3D

func _process(delta: float) -> void:
	if(self.omni_range > 0):
		self.omni_range = self.omni_range - 0.01;

func toggle_light() -> void: 
	self.omni_range = 0.8;
