extends Ship

onready var cpu_particles = [$CPUParticles,$CPUParticles2]

func moving(delta :float) -> void:
	.moving(delta)
	
	for i in cpu_particles:
		i.gravity = Vector3(0, 0,throttle * 2)
