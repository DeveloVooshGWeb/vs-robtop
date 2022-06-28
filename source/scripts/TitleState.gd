extends Node2D

var initialized:Array = [false, false];
var isLeft:bool = false;

onready var charDanceTitle:Node2D = get_node("CharCanvas/Char/charDanceTitle/AnimatedSprite");
onready var logoBumpin:AnimatedSprite = get_node("LogoCanvas/Logo/logoBumpin/AnimatedSprite");
onready var titleEnter:AnimatedSprite = get_node("TitleEnter");
onready var enterTimer:Timer = get_node("EnterTimer");

var switching:bool = false;

func _initialize():
	charDanceTitle.frames = Assets.getSpriteFrames("title/chars/2");
	charDanceTitle.play("danceLeft");
	logoBumpin.play("default");
	
	enterTimer.connect("timeout", self, "_switch");
	
	initialized[0] = true;
	SceneTransition.connect("finished", self, "_sceneLoaded");
	SceneTransition.init();

func _ready():
	var thread:Thread = Thread.new();
	thread.start(self, "_initialize");
	pass;

func _sceneLoaded():
	BeatHandler.init(Sound.playMusic("rub", 0.5, true, "My secret key!!!".to_ascii()), 128);
	BeatHandler.connect("beatHit", self, "beatHit");
	initialized[1] = true;

func beatHit(curBeat:int):
	print(curBeat);
	if !initialized.has(false):
		if isLeft:
			charDanceTitle.play("danceLeft");
		else:
			charDanceTitle.play("danceRight");
		isLeft = !isLeft;
		charDanceTitle.frame = 0;
		logoBumpin.frame = 0;

func _switch():
	SceneTransition.switch("MainMenuState");

func _process(delta):
	if (!initialized.has(false)):
		if (!switching && Input.is_action_just_pressed("ui_accept")):
			switching = true;
			Sound.play("confirmMenu");
			titleEnter.play("pressed");
			enterTimer.start(1);
	pass;

func _fixed_process(delta):
	queue_free();
	pass;
