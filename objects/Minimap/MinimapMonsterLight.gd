class_name MinimapMonsterLight extends OmniLight3D

func _process(delta: float) -> void:
	handle_flash();
	handle_unflash();

func flash() -> void: 
	self.omni_range = 0;
	self.light_energy = 5.0;

func handle_flash() -> void:
	if(Input.is_action_just_pressed("flash_minimap_light")):
		flash();

func handle_unflash() -> void:
	var snapped_le: String = str((snapped(self.light_energy, 0.1)));
	if(self.omni_range < 0.7):
		self.omni_range += 0.05;
	if(snapped_le != "0"):
		self.light_energy -= 0.1;
