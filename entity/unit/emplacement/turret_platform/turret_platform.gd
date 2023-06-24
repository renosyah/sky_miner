extends Emplacement

onready var flag = $flagpole/flag

func _ready():
	flag.color = color_coat
	flag.apply()
