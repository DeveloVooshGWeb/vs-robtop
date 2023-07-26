extends Node2D

var font:FontFile;

# DEFINES
var volume:int = 10;
var _traySize:Vector2 = Vector2(240, 90);
var barHeights:float = 4;
var windowScale:float = 1;

func _ready():
	font = Assets.getTtf("nokiafc22");

func _draw():
	var windowSize:Vector2i = get_tree().root.size;
	if (windowSize.x >= windowSize.y):
		windowScale = windowSize.y / 405.0;
	else:
		windowScale = windowSize.x / 720.0;
	if (windowScale > 1):
		windowScale = 1;
	
	var traySize:Vector2 = _traySize / windowScale;
	var trayPosX:float = (1920.0 - traySize.x) / 2.0;
	draw_rect(Rect2(trayPosX, 0, traySize.x, traySize.y), Color(0, 0, 0, 0.5));
	draw_string(font, Vector2(trayPosX, 80 / windowScale), "VOLUME", HORIZONTAL_ALIGNMENT_CENTER, traySize.x, 26 / windowScale, Color.WHITE);
	for i in range(10):
		var ip1:float = i + 1;
		var opacity:float = 1.0;
		if (ip1 > volume):
			opacity = 0.5;
		draw_rect(Rect2(trayPosX + (8 + (i * 23) / windowScale), (48 - barHeights * ip1) / windowScale, 14 / windowScale, barHeights * ip1 / windowScale), Color(1, 1, 1, opacity));
	
func _process(_delta):
	queue_redraw();
