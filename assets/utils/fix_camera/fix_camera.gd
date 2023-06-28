extends Spatial
class_name FixCamera

onready var _camera = $Spatial/Camera

func set_distance(_distance :float):
	_camera.translation.z = clamp(_distance, 10, 25)
	
func get_camera() -> Camera:
	return _camera

func capture_screenshot():
	var camera_image :Image = _camera.get_viewport().get_texture().get_data()
	camera_image.flip_y()
	
	var texture = ImageTexture.new()
	texture.create_from_image(camera_image)
	
	var _time :Dictionary = Time.get_time_dict_from_system()
	var _file_name :String = "image_ss_{hour}-{minute}-{second}.png".format(_time)
	var _path :String = "%s/%s" % [OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS), _file_name]
	
	if OS.request_permissions():
		ResourceSaver.save(_path, texture)
