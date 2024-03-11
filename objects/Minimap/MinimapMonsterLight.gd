class_name MinimapMonsterLight extends OmniLight3D

func _process(delta: float) -> void:
	if(self.omni_range < 0.7):
		self.omni_range = self.omni_range + 0.05;
	if(self.light_energy > 0.1):
		self.light_energy = self.light_energy - 0.1;

func toggle_flash() -> void: 
	self.omni_range = 0;
	self.light_energy = 5.0;
