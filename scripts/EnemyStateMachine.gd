# EnemyStateMachine.gd
class_name EnemyStateMachine extends Node

@export var roaming_state: EnemyState;
@export var ambush_state: EnemyState;
@onready var current_state: EnemyState = roaming_state;

func set_state(state: Enums.EnemyState) -> void:
	
	match(state):
		Enums.EnemyState.ROAMING:
			current_state = roaming_state;
		Enums.EnemyState.AMBUSH:
			current_state = ambush_state;
		_:
			return;
			
	current_state.start();
