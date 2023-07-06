extends Spatial
class_name InventoryItem

signal picked_up(_item)
signal droped(_item)

export var item_name :String
export var enable_pickup :bool

var _pickup_area :Area
var _collision :CollisionShape
var _interact_tween :Tween
var _sound :AudioStreamPlayer3D

func _ready():
	set_as_toplevel(enable_pickup)
	
	_pickup_area = Area.new()
	_pickup_area.monitoring = enable_pickup
	_pickup_area.monitorable = false
	_pickup_area.connect("body_entered", self, "_body_entered")
	add_child(_pickup_area)
	
	var _shape :SphereShape = SphereShape.new()
	_shape.radius = 0.44
	
	_collision = CollisionShape.new()
	_collision.shape = _shape
	_pickup_area.add_child(_collision)
	
	_interact_tween = Tween.new()
	add_child(_interact_tween)
	
	_sound = AudioStreamPlayer3D.new()
	_sound.unit_size = Global.sound_amplified
	add_child(_sound)
	
	set_process(enable_pickup)
	
func _process(delta):
	rotate_y(4 * delta)
	
func _body_entered(body):
	pickup(body)
	
func equip():
	visible = true
	
func unequip():
	visible = false
	
func pickup(_by :BaseUnit):
	if not is_instance_valid(_by):
		return
		
	if _by.get("inventories") == null:
		return
		
	if _by.is_dead:
		return
		
	_pickup_area.set_deferred("monitoring", false)
	var _pos :Vector3 = global_transform.origin
	
	yield(get_tree(), "idle_frame")
	
	get_parent().remove_child(self)
	_by.add_child(self)
	_by.inventories.append(self)
	
	var _dir :Vector3 = _pos.direction_to(_by.global_transform.origin)
	var _dis :float = _pos.distance_to(_by.global_transform.origin)
	
	_interact_tween.interpolate_property(
		self, "translation", _pos, _pos + _dir * _dis, 0.25, Tween.TRANS_SINE
	)
	_interact_tween.start()
	
	picked_up()
	
	yield(_interact_tween,"tween_completed")
	set_as_toplevel(false)
	visible = false
	set_process(false)
	
func picked_up():
	emit_signal("picked_up", self)
	
	
func drop(_to :Node):
	var parent = get_parent()
	if parent.get("inventories") == null:
		return
		
	var _pos :Vector3 = global_transform.origin
	
	yield(get_tree(), "idle_frame")
	
	parent.inventories.erase(self)
	set_as_toplevel(true)
	parent.remove_child(self)
	_to.add_child(self)
	visible = true
	
	var _dir :Vector3 = Vector3.FORWARD * parent.global_transform.basis.z
	
	_interact_tween.interpolate_property(
		self, "translation", _pos, _pos + _dir * rand_range(1,3), 0.25, Tween.TRANS_BOUNCE
	)
	_interact_tween.start()
	
	droped()
	
	yield(_interact_tween,"tween_completed")
	_pickup_area.set_deferred("monitoring", true)
	set_process(true)

func droped():
	emit_signal("droped", self)
	
	
