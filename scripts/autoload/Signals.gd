# Signals.gd
# Author: Jamie Rossiter
# Last Updated: 20/04/24
# Autoload script that contains all signals
extends Node

# Inputs
signal move # When any one or more of WASD is pressed
signal try_shoot # When LMB and RMB are pressed simultaneously
signal try_reload # When 'R' key is pressed
signal aim # When RMB is pressed
signal try_lower # When RMB is released

# Player
signal shoot(ammo: int)
signal dry_fire
signal reload
