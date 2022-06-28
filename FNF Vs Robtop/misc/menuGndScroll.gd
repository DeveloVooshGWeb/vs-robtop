extends ParallaxBackground

export(float) var scrollSpeed = 600.0;

var menuGndWidth:float = 384.0;

func _process(delta):
	offset.x -= delta * scrollSpeed;
	if (offset.x <= -menuGndWidth):
		offset.x += menuGndWidth;
