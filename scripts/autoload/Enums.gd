# Enums.gd
extends Node

enum Direction {
	NORTH,
	SOUTH,
	EAST,
	WEST
}

enum EnemyState {
	IDLE,
	ROAMING,
	AMBUSH,
	CHASE
}

enum EnemyDirection {
	BACKWARDS,
	FORWARDS
}
