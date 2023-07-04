extends GroundUnit
class_name Hero

const hit_melee_sounds = [
	preload("res://assets/sounds/hero/hit_melee_1.wav"), 
	preload("res://assets/sounds/hero/hit_melee_2.wav"), 
	preload("res://assets/sounds/hero/hit_melee_3.wav")
]
func perform_attack():
	.perform_attack()
	
	_sound.stream = hit_melee_sounds[rand_range(0, 3)]
	_sound.play()
	
