extends Projectile

const explosions = [
	preload("res://assets/sounds/explosions/explosion_1.wav"),
	preload("res://assets/sounds/explosions/explosion_2.wav"),
	preload("res://assets/sounds/explosions/explosion_3.wav")
]

onready var explosion_1 = $Explosion1
onready var explosion_timeout = $explosion_timeout
onready var body = $body
onready var sound = $AudioStreamPlayer3D

var guided_direction :Vector3

func _ready():
	sound.unit_size = Global.sound_amplified
	visible = false

func projectile_travel(delta):
	_direction = _get_pos().direction_to(guided_direction)
	look_at(guided_direction, Vector3.UP)
	
	.projectile_travel(delta)
	
	if _get_pos().distance_to(guided_direction) < 1:
		_launching = false
		projectile_dismiss()
		set_process(false)
		return

func launch():
	.launch()
	
	body.visible = true
	visible = true
	
	
func projectile_dismiss():
	.projectile_dismiss()
	
	body.visible = false
	explosion_1.emitting = true
	
	sound.stream = explosions[rand_range(0, explosions.size())]
	sound.play()
	
	explosion_timeout.start()
	
	# prevent being used
	_launching = true
	
func _on_explosion_timeout_timeout():
	visible = false
	
	# recycle after explode
	_launching = false

