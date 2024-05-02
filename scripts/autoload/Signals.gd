extends Node

# Inputs
signal player_move # When any one or more of WASD is pressed
signal player_try_shoot # When LMB and RMB are pressed simultaneously
signal player_try_reload # When 'R' key is pressed
signal player_aim # When RMB is pressed
signal player_try_lower # When RMB is released

# Player
signal player_shoot(ammo: int)
signal player_dry_fire
signal player_reload

# Enemy
signal enemy_step(position: Vector3)
