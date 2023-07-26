extends Node2D

@onready var canvas:CanvasLayer = get_node("Canvas");
@onready var renderer:Node2D = canvas.get_node("Renderer");
@onready var timer:Timer = get_node("Timer");

var timerSecs:float = 1.75;
var tween:Tween;
var volume:int = 10;

func placeBelow():
	canvas.layer = -128;
	canvas.visible = false;

func placeAbove():
	canvas.layer = 126;
	canvas.visible = true;

func _ready():
	timer.timeout.connect(Callable(self, "timeout"));
	InputHandler.justPressed.connect(Callable(self, "jp"));

func timeout():
	timer.stop();
	tween = get_tree().create_tween().set_parallel(true);
	tween.tween_property(renderer, "position:y", -90 / renderer.windowScale, 0.05);
	tween.finished.connect(Callable(self, "placeBelow"));

func updateVolume():
	if (volume > 10):
		volume = 10;
	var db:float = -(32.0 * (1.0 - (volume / 10.0)));
	if (volume <= 0):
		volume = 0;
		db = -96;
	AudioServer.set_bus_volume_db(0, db);
	Sound.play("beep");
	renderer.volume = volume;

func jp(key:Key):
	match (key):
		KEY_F2:
			timer.stop();
			if (tween):
				tween.kill();
			volume -= 1;
			placeAbove();
			updateVolume();
			renderer.position.y = 0;
			timer.start(timerSecs);
		KEY_F3:
			timer.stop();
			if (tween):
				tween.kill();
			volume += 1;
			placeAbove();
			updateVolume();
			renderer.position.y = 0;
			timer.start(timerSecs);
