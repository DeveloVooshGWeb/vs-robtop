extends Node2D

# Man this is gonna be pain...
# Let's start with the Camera
onready var cam:Camera2D = get_node("Cam");
onready var camTimer:Timer = get_node("Timer");
# Ok now the objects
onready var objects:Node2D = get_node("Objects");
# Ok now the NON parallaxes
onready var bg:Node2D = objects.get_node("BG");
onready var gnd:KinematicBody2D = objects.get_node("Gnd");
# Now for the funi sprites
onready var bgSpr:Sprite = bg.get_node("Spr");
onready var gndSpr:Sprite = gnd.get_node("Spr");
# Alright now the player
onready var player:KinematicBody2D = objects.get_node("Player");
# Alright now the shiz
# Lemme move to Data.gd
# And i wrote it now time for physics

var camUpdateTime:float = 0.05;

var keyMap:Array = [
	"Left",
	"Right",
	"Up"
];

var vel:Vector2 = Vector2(256, -512);
var maxVelY:float = 256;
var gravity:float = 2;
var maxGravity:float = 128;
var gravityMultiplier:float = 1.09;
var curGravity:float = 0;

var curVelocity:Vector2 = Vector2.ZERO;

var jumping:bool = false;
var jumpY:float = 0;

func updateTheme():
	bgSpr.modulate = Data.platData.theme;
	gndSpr.modulate = Data.platData.theme;

func _ready():
	updateTheme();
	camTimer.connect("timeout", self, "updateCamera");
	camTimer.start(camUpdateTime);
	InputHandler.connect("pressed", self, "pressed");
	InputHandler.connect("justReleased", self, "justReleased");
	pass;

# Physics and stuff
#func _physics_process(delta):
##	var collider:KinematicCollision2D = player.move_and_collide(curVelocity * delta);
##	var collider:KinematicCollision2D = player.move_and_collide(curVelocity * delta);
##	player.move_and_slide(curVelocity, Vector2(0, -1))
##	curVelocity.x = 0;
##	if (!collider):
##		curVelocity.y += curGravity;
##		if (curVelocity.y > maxVelY):
##			curVelocity.y = maxVelY;
##	else:
##		curVelocity.y = 0;
##	updateY();
##	curVelocity.y += curGravity;
##	curGravity *= gravityMultiplier;
##	if (curGravity > maxGravity):
##		curGravity = 0.0 + maxGravity;
##	if (curVelocity.y > maxVelY):
##		curVelocity.y = maxVelY;
##	if (collider || !jumping):
##		curGravity = 0.0 + gravity;
##		curVelocity.y = 0;
##		jumping = false;
#	player.motion.y += 16;
#	if (player.motion.y > maxVelY):
#		player.motion.y = maxVelY;
##	if (jumping):
##		jumping = false;
#	pass;

func updateY():
	if (jumping):
		if (curVelocity.y != 0):
			curGravity *= gravityMultiplier;
			if (curGravity > maxGravity):
				curGravity = 0.0 + maxGravity;
		else:
			curVelocity.y = 0.0 + vel.y;
	else:
		curGravity = 0.0 + gravity;
	pass;

# Eh
func _process(delta):
	pass;

func updateCamera():
	cam.position.x = (floor((player.position.x + 960) / 1920) * 1920) + 960;

# Input
func pressed(keyName:String):
	var key:int = keyMap.find(keyName);
	match (key):
		0:
		#	player.motion.x = vel.x;
			player.slide(false, true);
		1:
		#	player.motion.x = vel.x;
			player.slide(false);
		2:
			player.jumping = true;
	pass;

func justReleased(keyName:String):
	var key:int = keyMap.find(keyName);
	match (key):
		0, 1:
			player.slide(true);
		2:
			player.jumping = false;
