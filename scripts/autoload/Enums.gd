# Enums.gd
# Author: Jamie Rossiter
# Last Updated: 21/04/24
# Autoload script that aggregates all enumerations
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

enum EnemyDirection {
    BACKWARDS,
    FORWARDS
}