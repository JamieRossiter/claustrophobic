# Audio.gd
extends Node

@export var shoot: AudioStreamPlayer3D;
@export var tinnitus: AudioStreamPlayer3D;
@export var dry_fire: AudioStreamPlayer3D;

var low_pass_filter: AudioEffectLowPassFilter = AudioServer.get_bus_effect(AudioServer.get_bus_index("SFX"), 0);
var has_tinnitus_deactivated: bool = false;

func _ready() -> void:
	self._connect_signals();

func _process(delta: float) -> void:
	# Handle tinnitus deactivation
	if(not tinnitus.playing and not has_tinnitus_deactivated):
		has_tinnitus_deactivated = true;
		deactivate_tinnitus();

func _connect_signals() -> void:
	Signals.player_dry_fire.connect(_play_dry_fire);
	Signals.player_shoot.connect(_play_shoot);

func _play_shoot(_ammo: int) -> void:
	shoot.play();
	if(not tinnitus.playing):
		activate_tinnitus();

func _play_dry_fire() -> void:
	dry_fire.play();

func activate_tinnitus() -> void:
	tinnitus.play();
	has_tinnitus_deactivated = false;
	var tinnitus_onset_tween: Tween = create_tween();
	tinnitus_onset_tween.tween_property(low_pass_filter, "cutoff_hz", 500, 1.5);

func deactivate_tinnitus() -> void:
	var tinnitus_offset_tween: Tween = create_tween();
	tinnitus_offset_tween.tween_property(low_pass_filter, "cutoff_hz", 20500, 0.5);
