extends Ship

onready var cpu_particles = [$CPUParticles,$CPUParticles2]

onready var _main_body = $main_body
onready var _material :Material = _main_body.get_surface_material(2).duplicate()

func _ready():
	_material.albedo_color = color_coat
	_main_body.set_surface_material(2, _material)

func moving(delta :float) -> void:
	.moving(delta)
	
	for i in cpu_particles:
		i.gravity = Vector3(0, 0,throttle * 2)
