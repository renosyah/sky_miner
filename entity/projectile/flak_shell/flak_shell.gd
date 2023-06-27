extends Projectile

onready var cpu_particles = $CPUParticles
onready var explosion_timeout = $explosion_timeout
onready var mesh_instance = $MeshInstance

func _ready():
	visible = false

func launch():
	.launch()
	
	mesh_instance.visible = true
	visible = true
	
	
func projectile_dismiss():
	.projectile_dismiss()
	
	mesh_instance.visible = false
	cpu_particles.emitting = true
	explosion_timeout.start()
	
	# prevent being used
	_launching = true
	
func _on_explosion_timeout_timeout():
	visible = false
	
	# recycle after explode
	_launching = false
