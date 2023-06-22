extends AirShip

onready var blade_r = $blade_r
onready var blade_l = $blade_l

onready var _main_body = $main_body
onready var _flap = $flaps/flap

onready var _material :Material = _main_body.get_surface_material(2).duplicate()
onready var flaps = $flaps

var flaps_rotating :float

func _ready():
	_material.albedo_color = color_coat
	_main_body.set_surface_material(2, _material)
	_flap.set_surface_material(0, _material)
	turrets = [$mg, $mg2, $mg3]

func moving(delta :float) -> void:
	.moving(delta)
	
	var rotating = clamp(throttle * 25, 0, 10)
	
	blade_r.rotate_z(rotating * delta)
	blade_l.rotate_z(-rotating * delta)
	
	flaps_rotating = lerp(flaps_rotating, rotate_direction * 45, 15 * delta)
	flaps.rotation_degrees.y = -flaps_rotating
