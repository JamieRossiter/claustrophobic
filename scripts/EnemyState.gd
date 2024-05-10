# EnemyState.gd
class_name EnemyState extends Node

func start() -> void:
	pass;

func stop() -> void:
	pass;

func _init_timer(timer: Timer, callback: Callable) -> void:
	timer.timeout.connect(callback);
	self.add_child(timer);

func _start_timer(timer: Timer, interval: float) -> void:
	timer.wait_time = interval;
	timer.start();

func _step_toward_target_index(enemy: Enemy, level: Level) -> void:
	if(enemy.current_target_index > enemy.current_position_index):
		enemy.current_position_index += 1;
	else: 
		enemy.current_position_index -= 1;	
	enemy._move_to_position(level.get_position_from_index(enemy.current_position_index));
	Signals.enemy_step.emit();
