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
onready var _tween = $Tween

func _ready():
	_icon.texture = load(icon)
	_fire_rate.max_value = _turret.fire_rate
	_reload.max_value = _turret.reload_time
	_border.modulate = color
	
	_turret.connect("fired", self, "_turret_fired")
	_turret.connect("reload", self, "_turret_reload")
	_ammo.text = "%s" % _turret.ammo
	
func _process(_delta):
	var _reload_time :float = _turret.current_reload_time()
	_fire_rate.visible = _reload_time < 0.1
	_fire_rate.value = _turret.current_fire_rate_time()
	_reload.value = _reload_time
	
func _turret_reload(_tr :Turret, _is_finish :bool):
	_ammo.text = "%s" % _tr.ammo
	
func _turret_fired(_tr :Turret):
	_ammo.text = "%s" % _tr.ammo
	_ammo.rect_pivot_offset = _ammo.rect_size / 2
	_tween.interpolate_property(_ammo,"rect_scale",Vector2.ONE * 1.2, Vector2.ONE,0.2,Tween.TRANS_BOUNCE)
	_tween.start()
	
	







