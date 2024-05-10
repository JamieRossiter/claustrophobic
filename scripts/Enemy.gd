# Enemy.gd
class_name Enemy extends CharacterBody3D

@onready var original_position: Vector3 = self.position;
@onready var current_position_index: int;
@onready var current_target_index: int = -1;
@export var state_machine: EnemyStateMachine;

func _ready() -> void:
	state_machine.set_state(Enums.EnemyState.ROAMING);

func at_target_index() -> bool:
	return current_position_index == current_target_index;
	
func _move_to_position(new_position: Vector3) -> void:
	position = new_position;
	position.y = original_position.y; # Ensure enemy doesn't clip through floor
