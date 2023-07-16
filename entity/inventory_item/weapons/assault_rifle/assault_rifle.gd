extends InventoryItem
class_name RangeWeapon

const equip_animation_idle = "hold_range_weapon"
const equip_animation_walk = "hold_range_weapon"

const attack_animation = "attack_range_weapon"
const attack_bonus = 45
const attack_range = 8

const firing_sounds = [
	preload("res://assets/sounds/mg_firings/firing_1.wav"),
	preload("res://assets/sounds/mg_firings/firing_2.wav"),
	preload("res://assets/sounds/mg_firings/firing_3.wav")
]

onready var animation_player = $AnimationPlayer
onready var cpu_particles = $CPUParticles
onready var _sound = $AudioStreamPlayer3D

func _ready():
	can_stack = false
	stack_total = 1
	
func fire():
	cpu_particles.emitting = true
	animation_player.play("firing")

func _firing():
	_sound.stream = firing_sounds[rand_range(0, 3)]
	_sound.play()
