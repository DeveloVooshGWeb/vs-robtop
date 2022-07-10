extends Node2D

signal finished();
signal changingScene();

onready var canvas:CanvasLayer = get_node("Canvas");
onready var parent:Node2D = canvas.get_node("Parent");

onready var animationPlayer:AnimationPlayer = parent.get_node("Anim");
onready var text:Label = parent.get_node("Text");
onready var timer:Timer = parent.get_node("Timer");

var loadingTexts:PoolStringArray = [];

var animList:Array = ["fadeIn", "fadeOut"];
var defScenePath:String = "res://scenes/";
var sceneExt:String = "tscn";
var scn:String = "";
var firstTime:bool = false;
var stopListening:bool = false;
var queueStopMusic:bool = false;

var timerStarted:bool = false;
var timerSecs:float = 3;

func randomizeText():
	text.text = loadingTexts[randi() % loadingTexts.size()];

func _ready():
	hide();
	firstTime = true;
	loadingTexts = Assets.getText("loading", false, true).split("\n\n");
	timer.connect("timeout", self, "timeout")
	pass

func hide():
	parent.modulate.a = 0.0;

func init():
	if (firstTime):
		firstTime = false;
		emit_signal("finished");

func placeBelow():
	canvas.layer = -128;

func placeAbove():
	canvas.layer = 127;

func fadeOut():
	animationPlayer.play("fadeOut");

func fadeIn():
	animationPlayer.play("fadeIn");

func _process(delta):
	if (!stopListening):
		placeAbove();
		var animName:String = animationPlayer.assigned_animation;
		if (animName == ""):
			placeBelow();
			hide();
			return;
		if (animationPlayer.current_animation_position >= 1.0):
			match (animName):
				"fadeIn":
					var thread:Thread = Thread.new();
					if (scn != null):
						stopListening = true;
						thread.start(self, "_chscn");
					elif (!timerStarted):
						thread.start(self, "fadeOut");
				"fadeOut":
					text.text = "";
					animationPlayer.play("RESET");
					emit_signal("finished");
				_:
					placeBelow();
					hide();
		elif (!animList.has(animName)):
			placeBelow();
			hide();

func _chscn():
	emit_signal("changingScene");
	get_tree().change_scene_to(load(scn));
	if (queueStopMusic):
		Sound.stopAll();
	if (!timerStarted):
		fadeOut();
	stopListening = false;

func switch(inputScene:String, stopMusic:bool = false):
	queueStopMusic = stopMusic;
	FPSCounter.get_node("FPSCanvas/FPS").visible = true;
	Data.disableInput = false;
	scn = defScenePath + inputScene + "." + sceneExt;
	var thread:Thread = Thread.new();
	thread.start(self, "fadeIn");

func switchAbsolute(inputScene:String):
	FPSCounter.get_node("FPSCanvas/FPS").visible = true;
	Data.disableInput = false;
	scn = inputScene + "." + sceneExt;
	var thread:Thread = Thread.new();
	thread.start(self, "fadeIn");

func switchWithText(inputScene:String):
	FPSCounter.get_node("FPSCanvas/FPS").visible = true;
	timerStarted = true;
	timer.start(timerSecs);
	randomizeText();
	switch(inputScene);

func timeout():
	timer.stop();
	timerStarted = false;
	fadeOut();
