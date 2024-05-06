extends Node

enum Direction {
	NORTH,
	SOUTH,
	EAST,
	WEST
}

enum EnemyState {
	ROAMING,
	IDLE,
	AGGRO,
	JUMPSCARE  
}

enum AggroState {
	NONE,
	AMBUSH,
	PREPARE_CHASE,
	CHASE
}

enum EnemyDirection {
	BACKWARDS,
	FORWARDS
}
