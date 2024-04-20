# InputHandler.gd
# Author: Jamie Rossiter
# Last Updated: 20/04/24
# Autoload script that handles all inputs globally
extends Node
    
func _physics_process(_delta: float) -> void:
    # Movement 
    handle_movement_input();

    # Try shoot
    if (Input.is_action_just_pressed("shoot") and Input.is_action_pressed("aim")):
        Signals.try_shoot.emit();

    # Try reload
    if(Input.is_action_just_pressed("reload") and Input.is_action_pressed("aim")):
        Signals.try_reload.emit();

func handle_movement_input() -> void:
    
    # Check is moving
    var is_moving: bool = (
        Input.is_action_pressed("move_south") or 
        Input.is_action_pressed("move_north") or
        Input.is_action_pressed("move_east") or
        Input.is_action_pressed("move_west")
    );

    # Check if aiming
    var is_aiming: bool = Input.is_action_pressed("aim"); 

    # Emit signal if moving and not aiming
    if(is_moving and not is_aiming):
        Signals.move.emit();    