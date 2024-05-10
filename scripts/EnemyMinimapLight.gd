# EnemyMinimapLight.gd

extends OmniLight3D

var flash_activated: bool = true;

func _ready() -> void:
	Signals.enemy_step.connect(_flash);

func _process(delta: float) -> void:
	# Unflash if in flashing state
	if(light_energy > 0):
		_unflash();

func _flash() -> void:
	if(flash_activated):
		light_energy = 2.5;

func _unflash() -> void:
	# Remove inherent unreliability of float comparison
	var snapped_le: String = str((snapped(light_energy, 0.1)));
	if(snapped_le != "0"):
		light_energy -= 0.1;
