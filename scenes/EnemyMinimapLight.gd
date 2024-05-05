extends OmniLight3D

func _ready() -> void:
	Signals.enemy_step.connect(_flash)

func _process(delta: float) -> void:
	# Unflash if in flashing state
	if(light_energy > 0):
		self._unflash();

func _flash(_pos: Vector3) -> void:
	omni_range = 1;
	light_energy = 2.5;

func _unflash() -> void:
	var snapped_le: String = str((snapped(light_energy, 0.1)));
#	if(omni_range < 0.7):
#		omni_range += 0.05;
	if(snapped_le != "0"):
		light_energy -= 0.1;
