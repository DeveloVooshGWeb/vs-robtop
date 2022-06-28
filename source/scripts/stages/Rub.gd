extends Node2D

onready var cam:Camera2D = get_node("Cam");

onready var bg:Sprite = cam.get_node("BG");
onready var gnd:Sprite = cam.get_node("Ground");

onready var gf:AnimatedSprite = cam.get_node("GF/AnimatedSprite");
onready var enemy:AnimatedSprite = cam.get_node("RobTop/AnimatedSprite");

var stopEnemyIdle:bool = false;
var curEnemyKey:int = 0;

var isRight:bool = false;

func col(col:Color):
	bg.modulate = col;
	gnd.modulate = col;

func _ready():
	col(Color8(50, 100, 95, 255));
	enemy.play("idle");
	gf.visible = false;
	pass;

func _process(delta):
	if (!stopEnemyIdle):
		if (!isRight):
			if (enemy.frame >= 4):
				enemy.frame = 0;
		else:
			if (enemy.frame <= 3):
				enemy.frame = 4;
	
#	var keys:PoolStringArray = [
#		"ui_up",
#		"ui_left",
#		"ui_down",
#		"ui_right"
#	];
#
#	var keyMap:Array = [
#		Input.is_action_pressed(keys[0]),
#		Input.is_action_pressed(keys[1]),
#		Input.is_action_pressed(keys[2]),
#		Input.is_action_pressed(keys[3])
#	];
#
#	if (keyMap.has(true)):
#		for i in range(keyMap.size()):
#			if (keyMap[i]):
#				curEnemyKey = i;
#				match (curEnemyKey):
#					0:
#						enemy.play("up");
#					1:
#						enemy.play("left");
#					2:
#						enemy.play("down");
#					3:
#						enemy.play("right");
#				if (enemy.frame > 1):
#					enemy.frame = 0;
#		stopEnemyIdle = true;
#	elif (stopEnemyIdle && enemy.playing && enemy.animation != "idle" && enemy.frame >= 8):
	enemy.play("idle");
	stopEnemyIdle = false;
	pass;

func stepHit(steps:int):
	pass;

func beatHit(beats:int):
	if (!stopEnemyIdle):
		enemy.play("idle");
	if (!isRight):
		gf.play("danceLeft");
		if (!stopEnemyIdle):
			enemy.frame = 0;
	else:
		gf.play("danceRight");
		if (!stopEnemyIdle):
			enemy.frame = 4;
	gf.frame = 0;
	isRight = !isRight;
	pass;
