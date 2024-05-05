# Enemy.gd
# Author: Jamie Rossiter
# Last Updated: 26/04/24
# Handles all data and logic for the Enemy
class_name Enemy extends CharacterBody3D

@onready var original_position: Vector3 = self.position;

func _ready():
	_connect_signals();

func _connect_signals() -> void:
	Signals.enemy_step.connect(_move_to_position);

func _move_to_position(new_position: Vector3) -> void:
	self.position = new_position;
	self.position.y = original_position.y; # Ensure that enemy doesn't clip through floor
