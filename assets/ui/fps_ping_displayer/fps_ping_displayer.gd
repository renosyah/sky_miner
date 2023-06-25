extends MarginContainer

onready var os = $VBoxContainer/HBoxContainer9/os
onready var platform = $VBoxContainer/HBoxContainer9/platform
onready var cpu = $VBoxContainer/HBoxContainer8/cpu
onready var driver = $VBoxContainer/HBoxContainer8/driver

onready var fps = $VBoxContainer/HBoxContainer/fps
onready var drawn = $VBoxContainer/HBoxContainer/drawn

onready var memory_usage = $VBoxContainer/HBoxContainer2/memory_usage
onready var memory_peak = $VBoxContainer/HBoxContainer2/memory_peak

onready var ping = $VBoxContainer/HBoxContainer6/ping

# Called when the node enters the scene tree for the first time.
func _ready():
	os.text = "Os : %s" % OS.get_model_name()
	platform.text = "Platform : %s" % OS.get_name()
	cpu.text = "Cpu : %s" % OS.get_processor_name()
	driver.text = "Driver : %s" % OS.get_video_driver_name(OS.get_current_video_driver())
	
	Network.connect("on_ping", self, "on_ping")
	
func on_ping(_ping :int):
	ping.text = "Ping : " + str(_ping) + "/ms"
	
func _process(_delta):
	fps.text = "Current : %s/Fps" % Engine.get_frames_per_second()
	drawn.text = "Drawn: %s" % Performance.get_monitor(Performance.RENDER_OBJECTS_IN_FRAME)
	
	memory_usage.text = "Usage : %s" % format_size(OS.get_static_memory_usage())
	memory_peak.text = "Peak : %s" % format_size(OS.get_static_memory_peak_usage())
	
	#send.text "Send : %s " % get
	
func format_size(size :int):
	var b :float = size
	var k :float = size/1024.0
	var m :float = ((size/1024.0)/1024.0)
	var g :float = (((size/1024.0)/1024.0)/1024.0)
	var t :float = ((((size/1024.0)/1024.0)/1024.0)/1024.0)

	if t > 1:
		return "%s TB" % t
	elif g > 1:
		return "%s GB" % g
	elif m > 1:
		return "%s MB" % m
	elif k > 1:
		return "%s KB" % k
	else:
		return "%s Bytes" % b
		
	return "";
	
