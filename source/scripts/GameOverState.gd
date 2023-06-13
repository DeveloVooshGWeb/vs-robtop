extends Node2D

@onready var deathSprite:AnimatedSprite2D = get_node("DeathSprite");
@onready var overlay:ColorRect = get_node("Overlay");
@onready var timer:Timer = get_node("Timer");
@onready var tween:Tween = get_tree().create_tween().set_parallel(true);

var state:int = 0;
var deathMusic:AudioStreamPlayer;
var looping:bool = false;

var offsets:Array = [
	{"death": Vector2(-15, 40), "loop": Vector2(-15, 40), "confirm": Vector2(-15, 9)},
	{"death": Vector2(0, -250), "loop": Vector2(0, -250), "confirm": Vector2(0, -250)},
	{"death": Vector2.ZERO, "loop": Vector2.ZERO, "confirm": Vector2.ZERO}
]

var timerSecs:Array = [
	2.5,
	0,
	2.5
]

func loop():
	looping = true;
	deathSprite.play("loop");
	deathMusic = Sound.playMusic("gameOver" + str(state));
	pass;

func hookSignals():
	InputHandler.connect("justPressed", Callable(self, "justPressed"));
	timer.connect("timeout", Callable(self, "loop"));
	pass;

func _ready():
	hookSignals();
	
	state += Data.goState;
	deathSprite.frames = Assets.getSpriteFrames("chars/BFGameOver/" + str(state));
	
	deathSprite.play("death");
	Sound.play("lose");
	
	timer.start(timerSecs[state]);
	pass;

func justPressed(key:String):
	if (looping):
		if (key == "Enter"):
			looping = false;
			if (deathMusic):
				if (deathMusic.stream):
					Sound.stopMusic(deathMusic.stream);
			deathSprite.play("confirm");
			Sound.play("gameOverEnd");
	pass;

func _process(delta):
	deathSprite.offset = offsets[state][deathSprite.animation];
	pass;
