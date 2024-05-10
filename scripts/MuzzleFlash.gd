# MuzzleFlash.gd
extends OmniLight3D

var flash_timer: Timer = Timer.new();

func _ready() -> void:
	# Init flash timer
	flash_timer.wait_time = 0.1;
	flash_timer.timeout.connect(_end_flash);
	self.add_child(flash_timer);
	# Connect flash to player shoot signal
	Signals.player_shoot.connect(_start_flash);

func _start_flash(_ammo: int) -> void:
	# Start timer for flash end
	flash_timer.start();
	self.omni_range = 1;

func _end_flash() -> void:
	# Remove the flash
	self.omni_range = 0;
