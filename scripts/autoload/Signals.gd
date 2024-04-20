# Signals.gd
# Author: Jamie Rossiter
# Last Updated: 20/04/24
# Autoload script that contains all signals
extends Node

# Inputs
signal move # When any one or more of WASD is pressed
signal try_shoot # When LMB and RMB are pressed simultaneously
signal try_reload # When 'R' key is pressed

# Player
signal shoot
signal dry_fire
signal reload