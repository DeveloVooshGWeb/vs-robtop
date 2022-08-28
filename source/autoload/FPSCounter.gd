extends Node2D

func _ready():
	pass

func _process(delta):
#	$FPSCanvas/FPS.visible = false;
	$FPSCanvas/FPS.text = "FPS: " + str(Engine.get_frames_per_second());
	pass
