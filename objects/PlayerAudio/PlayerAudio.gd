"""
PlayerAudio.gd
Handles all logic involving player audio, such as AudioStreamPlayers.
Author: Jamie Rossiter
"""
class_name PlayerAudio extends Node3D

# General variables
var low_pass_filter: AudioEffectLowPassFilter = AudioServer.get_bus_effect(AudioServer.get_bus_index("SFX"), 0);
var has_tinnitus_deactivated: bool = false;

# Onready variables
@onready var player: Player = get_parent();
@onready var tinnitus_sfx: AudioStreamPlayer = $Sfx_Tinnitus;
@onready var gunshot_sfx: AudioStreamPlayer3D = $Sfx_Gunshot;
@onready var dry_sfx: AudioStreamPlayer3D = $Sfx_Dry;
	
func _ready() -> void:
	# Connect signals
	player.shoot.connect(shoot);
	player.shoot_dry.connect(shoot_dry);
	
func _process(delta: float):
	handle_tinnitus();

func shoot(ammo: int):
	gunshot_sfx.play();
	if(!tinnitus_sfx.playing):
		activate_tinnitus();

func shoot_dry():
	dry_sfx.play();

func handle_tinnitus():
	if(!tinnitus_sfx.playing and !has_tinnitus_deactivated):
		has_tinnitus_deactivated = true;
		deactivate_tinnitus();

func activate_tinnitus() -> void:
	tinnitus_sfx.play();
	has_tinnitus_deactivated = false;
	var tinnitus_onset_tween: Tween = create_tween();
	tinnitus_onset_tween.tween_property(low_pass_filter, "cutoff_hz", 2000, 1.5);

func deactivate_tinnitus() -> void:
	var tinnitus_offset_tween: Tween = create_tween();
	tinnitus_offset_tween.tween_property(low_pass_filter, "cutoff_hz", 20400, 0.5);
