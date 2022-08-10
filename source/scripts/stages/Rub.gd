extends Node2D

onready var cam:Camera2D = get_node("Cam");

onready var bg:Sprite = cam.get_node("BG");
onready var gnd:Sprite = cam.get_node("Ground");

onready var gf:AnimatedSprite = cam.get_node("GF/AnimatedSprite");
onready var bf:AnimatedSprite = cam.get_node("BF/AnimatedSprite");
onready var enemy:AnimatedSprite = cam.get_node("RobTop/AnimatedSprite");

var curEnemyKey:int = 0;

var isRight:bool = false;

var bfIdle:bool = true;
var bfHold:bool = false;
var bfHoldKey:int = -1;
var bfMissing:bool = false;

var enmIdle:bool = true;
var enmHold:bool = false;
var enmHoldKey:int = -1;

var keyMap:Array = ["left", "down", "up", "right"];

var animMultiplier:float = 1;

func col(col:Color):
	bg.modulate = col;
	gnd.modulate = col;

func _ready():
	col(Color8(50, 100, 95, 255));
	bf.play("idle");
	enemy.play("idle");
	pass;

func _process(delta):
#	if (!stopEnemyIdle):
#		if (!isRight):
#			if (enemy.frame >= 4):
#				enemy.stop();
#		else:
#			if (enemy.frame <= 3):
#				enemy.stop();

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
#	stopEnemyIdle = false;
	if (bf.animation == "idle"):
		bf.speed_scale = BeatHandler.bpm / (90.0 / animMultiplier);
	else:
		bf.speed_scale = 1;
	
	if (enemy.animation == "idle"):
		enemy.speed_scale = BeatHandler.bpm / (90.0 / animMultiplier);
	else:
		enemy.speed_scale = 1;
	
	if (bfHold && keyMap.has(bf.animation) && bf.frame > 1):
		bf.frame = 0;
	
	if (bfIdle && !bfHold && bf.animation != "idle" && bf.frame + 1 >= bf.frames.get_frame_count(bf.animation)):
		bf.play("idle");
		bf.frame = 0;
	
	if (enmHold && keyMap.has(enemy.animation) && enemy.frame > 1):
		enemy.frame = 0;
	
	if (enmIdle && !enmHold && enemy.animation != "idle" && enemy.frame + 1 >= enemy.frames.get_frame_count(enemy.animation)):
		enemy.play("idle");
		enemy.frame = 0;
	pass;

func stepHit(steps:int):
	pass;

func beatHit(beats:int, countdown:bool = false):
	if (!isRight):
		gf.play("danceLeft");
	else:
		gf.play("danceRight");
	var bMod:int = int(1.0 / animMultiplier);
	if (bMod < 1):
		bMod = 1;
	if (beats % bMod == 0):
		if (bf.animation == "idle"):
			bf.frame = 0;
		if (enemy.animation == "idle"):
			enemy.frame = 0;
	isRight = !isRight;
	pass;

func bfNormal():
	bfIdle = true;
	bfHold = false;
	bfHoldKey = -1;
	pass;

func bfConfirmLoop(hk:int):
	bfIdle = false;
	bfHold = true;
	bfHoldKey = hk;
	bf.play(keyMap[bfHoldKey]);
	pass;

func bfConfirm(hk:int):
	bfIdle = false;
	bfHold = false;
	bfHoldKey = -1;
	bf.play(keyMap[hk]);
	bf.frame = 0;
	pass;

func bfMiss(direction:int):
	bfIdle = true;
	bfHold = false;
	bfHoldKey = -1;
	bf.play(keyMap[direction] + "Miss");
	pass;

func enmNormal():
	enmIdle = true;
	enmHold = false;
	enmHoldKey = -1;
	pass;

func enmConfirmLoop(hk:int):
	enmIdle = false;
	enmHold = true;
	enmHoldKey = hk;
	enemy.play(keyMap[enmHoldKey]);
	pass;

func enmConfirm(hk:int):
	enmIdle = false;
	enmHold = false;
	enmHoldKey = -1;
	enemy.play(keyMap[hk]);
	enemy.frame = 0;
	pass;
