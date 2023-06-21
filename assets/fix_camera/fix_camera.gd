extends Spatial
class_name FixCamera

onready var camera = $Spatial/Camera

func set_distance(_distance :float):
	camera.translation.z = clamp(_distance, 10, 25)
