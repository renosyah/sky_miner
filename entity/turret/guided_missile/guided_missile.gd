extends Turret

const launch = preload("res://assets/sounds/explosions/missile_away.wav")

onready var missile = $body/missiles/missile_1

onready var from = $body/gun/from
onready var laser = $body/gun/laser
onready var laser_pointing = $body/gun/laser_pointing
onready var laser_mesh = laser.mesh.duplicate() as CylinderMesh
onready var guided_timeout = $guided_timeout

var projectile_fired :Projectile

func _ready():
	max_ammo = clamp(max_ammo, 0 ,1)
	ammo = max_ammo
	
	laser.visible = false
	
	laser.mesh = laser_mesh

func reload_finish():
	.reload_finish()
	missile.visible = true
	
func firing(_projectile :Projectile, _target :BaseUnit):
	projectile_fired = _projectile
	laser.visible = true
	guided_timeout.start()
	
	_muzzle_position = from.global_transform.origin
	.firing(_projectile, _target)
	
	_sound.stream = launch
	_sound.play()
	
	missile.visible = false
	
func _process(_delta):
	if is_instance_valid(projectile_fired):
		projectile_fired.guided_direction = laser_pointing.global_transform.origin
	
func is_align(_target_pos :Vector3) -> bool:
	#.is_align(_target_pos)
	var _from_pos :Vector3 = _body.global_transform.origin
	var _dist :float = _from_pos.distance_to(_target_pos)
	var _to_pos :Vector3 = _from_pos + -_body.global_transform.basis.z * _dist
	_to_pos.y = _target_pos.y
	
	laser_mesh.height = _dist + 1.5
	laser.translation.z = -laser_mesh.height / 2
	laser_pointing.translation.z = -laser_mesh.height
	
	return true
	#return _to_pos.distance_to(_target_pos) < 5
	
func _on_guided_timeout_timeout():
	laser.visible = false
	projectile_fired = null













