extends Projectile

onready var mesh_instance = $MeshInstance

func _ready():
	visible = false

func launch():
	.launch()
	
	mesh_instance.visible = true
	visible = true
	
	
func projectile_dismiss():
	.projectile_dismiss()
	
	visible = false
