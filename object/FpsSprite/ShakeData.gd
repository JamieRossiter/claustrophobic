class_name ShakeData

var subject: Node = null;
var is_shaking: bool;
var elapsed_shake_time: float;
var shake_time: float = 10;
var shake_power: float;
var original_shake_pos: Vector2;

func _init(
	sub: Node, 
	shaking: bool, 
	elapsed_time: float, 
	time: float, 
	power: float, 
	original_pos: Vector2
) -> void:
	subject = sub;
	is_shaking = shaking;
	elapsed_shake_time = elapsed_time;
	shake_time = time;
	shake_power = power;
	original_shake_pos = original_pos;
