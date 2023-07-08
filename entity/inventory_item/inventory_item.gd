extends Spatial
class_name InventoryItem

signal picked_up(_item, _by)
signal droped(_item, _from)

export var item_id :String
export var item_name :String
export var icon :String
export var enable_pickup :bool

var _pickup_area :Area
var _collision :CollisionShape
var _interact_tween :Tween

func _ready():
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
	
	_reset()
	
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
		
	var _parent = get_parent()
	enable_pickup = false
	
	_pickup_area.set_deferred("monitoring", false)
	_parent.call_deferred("remove_child", self)
	yield(get_tree(), "idle_frame")
	
	_by.add_child(self)
	_by.inventories.append(self)
	
	picked_up(_by)
	_reset()
	
func picked_up(_by):
	emit_signal("picked_up", self, _by)
	
	
func drop(_to :Node):
	var _parent = get_parent()
	
	if _parent.get("inventories") == null:
		return
		
	enable_pickup = true
	_pickup_area.set_deferred("monitoring", true)
	_parent.call_deferred("remove_child", self)
	yield(get_tree(), "idle_frame")
	
	_to.add_child(self)
	_parent.inventories.erase(self)
	
	droped(_parent)
	
	_reset()
	translation = _get_rand_pos(_parent.global_transform.origin)
	
func droped(_from):
	emit_signal("droped", self, _from)
	
func _reset():
	translation = Vector3.ZERO
	rotation_degrees = Vector3.ZERO
	visible = enable_pickup
	
	set_as_toplevel(enable_pickup)
	set_process(enable_pickup)
	
func _get_rand_pos(from :Vector3) -> Vector3:
	var angle := rand_range(0, TAU)
	var distance := rand_range(1, 2)
	var posv2 = polar2cartesian(distance, angle)
	var posv3 = from + Vector3(posv2.x, 0, posv2.y)
	return posv3








