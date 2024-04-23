extends AnimationPlayer

var INITIAL_Y_POS: float = get_parent().position.y;
const TARGET_Y_POS: float = -0.4;
var is_reloading: bool;

func _ready() -> void:
	_connect_signals();

func _process(_delta: float) -> void:
	self.is_reloading = (self.current_animation == _get_animation_string("reload"));

func _connect_signals() -> void:
	Signals.shoot.connect(_shoot);
	Signals.reload.connect(_reload);
	Signals.aim.connect(_aim);
	Signals.try_lower.connect(_try_lower);
	self.animation_finished.connect(_on_animation_finished);

func _shoot(ammo: int) -> void:
	# If ammo is at 1, indicate the gun has used its last bullet (assuming ammo=-1 as normal)
	if(ammo == 1):
		self.current_animation = _get_animation_string("fire_empty");
		return;

	self.current_animation = _get_animation_string("fire");

func _reload() -> void:
	self.current_animation = _get_animation_string("reload");

func _aim() -> void:
	var aim_tween: Tween = create_tween();
	aim_tween.tween_property(get_parent(), "position:y", TARGET_Y_POS, 0.25);

# Try lowering the pistol, e.g. depending on if the player is reloading
func _try_lower() -> void:
	if(is_reloading): return;
	self._lower();
		
func _lower() -> void:
	var lower_tween: Tween = create_tween();
	lower_tween.tween_property(get_parent(), "position:y", INITIAL_Y_POS, 0.25);

func _on_animation_finished(anim_name: String) -> void:
	# Lower pistol if reloading finished
	if(anim_name == _get_animation_string("reload")):
		self._lower();

func _get_animation_string(anim_name: String) -> String:
	return "Pistol_" + anim_name.to_upper(); 

