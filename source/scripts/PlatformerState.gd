extends Node2D

# Man this is gonna be pain...

# Let's start with the Camera
@onready var cam:Camera2D = get_node("Cam");
@onready var camTimer:Timer = get_node("Timer");

# Ok now the bg and ground stuff
@onready var bg:Node2D = get_node("BG");
@onready var gnd:CharacterBody2D = get_node("Gnd");

# Now for the funi sprites
@onready var bgSpr:Sprite2D = bg.get_node("Spr");
@onready var gndSpr:Sprite2D = gnd.get_node("Spr");

# Alright now the player
@onready var player:CharacterBody2D = get_node("Player");

# Alright now the shiz
# Lemme move to Data.gd

# And now time for the camera and input shiz
var camUpdateTime:float = 0.05;
var keyMap:Array = [
	"Left",
	"Right",
	"Up"
];

func updateTheme():
	bgSpr.modulate = Data.platData.theme;
	gndSpr.modulate = Data.platData.theme;

# Initialization
func init():
	cam.make_current();
	updateTheme();
	camTimer.connect("timeout", Callable(self, "updateCamera"));
	camTimer.start(camUpdateTime);
	InputHandler.connect("pressed", Callable(self, "pressed"));
	InputHandler.connect("justReleased", Callable(self, "justReleased"));

func _ready():
	var thread:Thread = Thread.new();
	thread.start(Callable(self, "init"));
	pass;

# Eh
func _process(delta):
	pass;

# Update Camera
func updateCamera():
	cam.position.x = (int(player.position.x / 1920) * 1920) + 960;

# Input
func pressed(_key:Key):
	var keyName:String = OS.get_keycode_string(_key);
	var key:int = keyMap.find(keyName);
	match (key):
		0:
			player.slide(false, true);
		1:
			player.slide(false);
		2:
			player.jumping = true;
	pass;

func justReleased(_key:Key):
	var keyName:String = OS.get_keycode_string(_key);
	var key:int = keyMap.find(keyName);
	match (key):
		0, 1:
			player.slide(true);
		2:
			player.jumping = false;
