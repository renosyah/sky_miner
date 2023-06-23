extends Emplacement

func _ready():
	# just testing
	turrets = [$mg, $mg2, $mg3]
	
	for i in turrets:
		i.is_master = _check_is_master()
