extends Projectile

onready var cpu_particles = $CPUParticles
onready var explosion_timeout = $explosion_timeout
onready var mesh_instance = $MeshInstance

func _ready():
	visible = false

func launch():
	mesh_instance.visible = true
	visible = true
	.launch()
	
func stop():
	mesh_instance.visible = false
	cpu_particles.emitting = true
	explosion_timeout.start()
	set_process(false)
	
func _on_explosion_timeout_timeout():
	visible = false
	.stop()
