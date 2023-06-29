extends Projectile

const explosions = [
	preload("res://assets/sounds/explosions/explosion_1.wav"),
	preload("res://assets/sounds/explosions/explosion_2.wav"),
	preload("res://assets/sounds/explosions/explosion_3.wav")
]

onready var explosion_1 = $Explosion1
onready var explosion_timeout = $explosion_timeout
onready var body = $MeshInstance
onready var sound = $AudioStreamPlayer3D

func _ready():
	sound.unit_size = Global.sound_amplified
	visible = false


func launch():
	.launch()
	
	body.visible = true
	visible = true
	
	look_at(_target,Vector3.UP)
	
	
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






