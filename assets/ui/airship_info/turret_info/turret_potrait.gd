extends MarginContainer
class_name TurretPotrait

export var icon :String
export var turret_path :NodePath
export var color :Color

onready var _turret :Turret = get_node_or_null(turret_path)
onready var _icon = $icon
onready var _fire_rate = $fire_rate
onready var _reload = $reload
onready var _ammo = $ammo

onready var _border = $border

func _ready():
	_icon.texture = load(icon)
	_fire_rate.max_value = _turret.fire_rate
	_reload.max_value = _turret.reload_time
	_border.modulate = color
	
func _process(delta):
	if is_instance_valid(_turret):
		var _reload_time :float = _turret.current_reload_time()
		_fire_rate.visible = _reload_time < 0.1
		_fire_rate.value = _turret.current_fire_rate_time()
		_reload.value = _reload_time
		_ammo.text = "%s" % _turret.ammo
