extends Spatial
class_name ScreenMarker

enum Mode {
	show_offscreen
	show_onscreen
	show_always
}

export var camera :NodePath
export var icon : Texture = preload("res://addons/3d-marker/empty.png")
export var color : Color = Color.white
export(Mode) var mode := Mode.show_offscreen
export(Vector2) var screen_border_offset = Vector2( 80.0, 200.0 )
export(bool) var is_tracked = true setget _set_tracked

onready var _animate = $AnimationPlayer
onready var _marker_item :Sprite = $marker_item
onready var _marker_icon :Sprite3D = $marker_icon

onready var _target_node: Spatial = get_parent()
onready var _current_camera: Camera = get_node_or_null(camera)

func _ready():
	if icon:
		_marker_icon.texture = icon
		_marker_icon.modulate = color
		_marker_item.set_marker(icon, color)
		
	_marker_item.visible = false
	_marker_icon.visible = false
	
	var rect = _marker_item.get_rect().size
	if screen_border_offset.x < rect.x:
		screen_border_offset.x = rect.x
		
	if screen_border_offset.y < rect.y:
		screen_border_offset.y = rect.y
		
	set_process(is_tracked)
	
func _process(delta):
	if not is_instance_valid(_target_node):
		return
		
	if not is_instance_valid(_current_camera):
		return
		
	var pos :Vector3 = global_transform.origin
	var viewport_rect = _marker_item.get_viewport_rect()
	
	if _current_camera.is_position_behind(pos):
		return
		
	var target_2d_position: Vector2 = _current_camera.unproject_position(pos)
	_marker_item.position.x = clamp(target_2d_position.x, screen_border_offset.x, viewport_rect.size.x - screen_border_offset.x)
	_marker_item.position.y = clamp(target_2d_position.y, screen_border_offset.y, viewport_rect.size.y - screen_border_offset.y)
	
	if viewport_rect.has_point(target_2d_position):
		target_2d_position = _current_camera.unproject_position(_target_node.global_transform.origin)
		
	_marker_item.look_at(target_2d_position)
	
	var has_point :bool = viewport_rect.has_point(target_2d_position)
	var animate_playing :bool = _animate.is_playing()
	
	match (mode):
		Mode.show_offscreen:
			if animate_playing:
				return
				
			if has_point:
				if _marker_item.visible:
					_animate.play("hide")
					_marker_icon.visible = false
				return
				
			if not _marker_item.visible:
				_animate.play("show")
				_marker_icon.visible = true
				
		Mode.show_onscreen:
			if animate_playing:
				return
				
			if has_point:
				if _marker_item.visible:
					_animate.play("hide")
					_marker_icon.visible = true
				return
				
			if not _marker_item.visible:
				_animate.play("show")
				_marker_icon.visible = false
			
		Mode.show_always:
			_marker_item.visible = true
			_marker_icon.visible = true
			
			
func _set_tracked(tracked : bool):
	is_tracked = tracked
	if visible:
		_animate.play("hide")
		yield(_animate, "animation_finished")
		
	set_process(tracked)
	
func set_marker(icon :Texture, color :Color):
	_marker_item.set_marker(icon, color)
	
 
