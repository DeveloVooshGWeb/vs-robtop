extends Node2D

@onready var counter:Label = $FPSCanvas/FPS;
var counterSize:float;

func _ready():
	counterSize = counter.get_theme_default_font_size();
	pass

func _process(delta):
#	$FPSCanvas/FPS.visible = false;
	counter.text = "FPS: " + str(Engine.get_frames_per_second());
	var windowSize:Vector2i = get_tree().root.size;
	var windowScale:float;
	if (windowSize.x >= windowSize.y):
		windowScale = windowSize.y / 1080.0;
	else:
		windowScale = windowSize.x / 1920.0;
	if (windowScale > 1):
		windowScale = 1;
	# Dynamically adjusts the size on window resize
	counter.add_theme_font_size_override("font_size", counterSize / windowScale);
	pass
