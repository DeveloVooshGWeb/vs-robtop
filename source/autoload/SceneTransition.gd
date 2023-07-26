extends Node2D

signal finished();
signal changingScene();

@onready var canvas:CanvasLayer = get_node("Canvas");
@onready var parent:Node2D = canvas.get_node("Parent");

@onready var animationPlayer:AnimationPlayer = parent.get_node("Anim");
@onready var loader:AnimatedSprite2D = parent.get_node("Loading");
@onready var text:Label = parent.get_node("Text");
@onready var timer:Timer = parent.get_node("Timer");

var loadingTexts:PackedStringArray = [];

var animList:Array = ["fadeIn", "fadeOut"];
var defScenePath:String = "res://scenes/";
var sceneExt:String = "tscn";
var scn:String = "";
var scnThing:Node;
var firstTime:bool = false;
var stopListening:bool = false;
var queueStopMusic:bool = false;

var timerStarted:bool = false;
var timerSecs:float = 5;

var loaderTextPos:Vector2 = Vector2(1820, 980);

func randomizeText():
#	print(loadingTexts);
	text.text = loadingTexts[randi() % loadingTexts.size()];

func _ready():
#	hideF();
	firstTime = true;
	loadingTexts = Assets.getText("loading", false, true).split("\n\n");
	timer.connect("timeout", Callable(self, "timeout"));
#	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN);
	pass

#func hideF():
#	parent.modulate.a = 0.0;

func init():
	if (firstTime):
		firstTime = false;
		emit_signal("finished");

func placeBelow():
	canvas.layer = -128;
	canvas.visible = false;

func placeAbove():
	canvas.layer = 125;
	canvas.visible = true;

var animFin:bool = false;

func animFinished(animName:String):
	animationPlayer.animation_finished.disconnect(Callable(self, "animFinished"));
	match (animName):
		"fadeIn":
			_chscn();
#			Thread.new().start(Callable(self, "_chscn"));
		"fadeOut":
			text.text = "";
			loader.position = Data.vec2cen;
			emit_signal("finished");
			placeBelow();
		_:
			placeBelow();
#			hideF();

func fadeOut():
	animationPlayer.animation_finished.connect(Callable(self, "animFinished"));
	animationPlayer.play("fadeOut");

func fadeIn():
	animFin = false;
	animationPlayer.animation_finished.connect(Callable(self, "animFinished"));
	animationPlayer.play("fadeIn");

func _process(delta):
	if (!stopListening):
		placeAbove();
		var animName:String = animationPlayer.assigned_animation;
		if (animName == ""):
			placeBelow();
#			hideF();
			return;
#		if (animationPlayer.current_animation_position >= 1.0):
#			match (animName):
#				"fadeIn":
##					var thread:Thread = Thread.new();
#					if (scn != ""):
#						stopListening = true;
#						Thread.new().start(Callable(self, "_chscn"));
#					elif (!timerStarted):
#						fadeOut();
#				"fadeOut":
#					text.text = "";
#					animationPlayer.play("RESET");
#					loader.position = Data.vec2cen;
#					emit_signal("finished");
#				_:
#					placeBelow();
#					hideF();
		if (animationPlayer.current_animation_position < 1.0 && !animList.has(animName)):
			placeBelow();
#			hideF();

var timerFin:bool = false;

func _chscn():
	emit_signal("changingScene");
	if (weakref(get_tree().current_scene).get_ref()):
		get_tree().current_scene.free();
	if (timerStarted):
		scnThing = load(scn).instantiate();
	else:
		get_tree().change_scene_to_packed(load(scn));
	if (queueStopMusic):
		Sound.stopAll();
	if (timerFin):
		get_tree().root.add_child(scnThing);
	if (!timerStarted):
		fadeOut();
	stopListening = false;
	if (!timerFin):
		animFin = true;

func switch(inputScene:String, stopMusic:bool = false):
	queueStopMusic = stopMusic;
	FPSCounter.get_node("FPSCanvas/FPS").visible = true;
	Data.disableInput = false;
	scn = defScenePath + inputScene + "." + sceneExt;
	fadeIn();

func switchAbsolute(inputScene:String):
	FPSCounter.get_node("FPSCanvas/FPS").visible = true;
	Data.disableInput = false;
	scn = inputScene + "." + sceneExt;
	fadeIn();

func switchWithText(inputScene:String, stopMusic:bool = false):
	loader.position = loaderTextPos;
	randomizeText();
	timerStarted = true;
	timerFin = false;
	timer.start(timerSecs);
	switch(inputScene, stopMusic);

func timeout():
	timer.stop();
	if (animFin):
		timerStarted = false;
		get_tree().root.add_child(scnThing);
		fadeOut();
	else:
		timerFin = true;
