extends Turret

onready var firerate = $firerate
onready var animation_player = $AnimationPlayer

func _process(delta):
	if firerate.is_stopped() and _firing:
		animation_player.play("firing")
		firerate.start()
