extends Turret

onready var animation_player = $AnimationPlayer

func firing():
	.firing()
	animation_player.play("firing")
