extends Node2D

@onready var cam:Camera2D = get_node("Cam");

@onready var bg:Sprite2D = get_node("BG");
@onready var gnd:Sprite2D = get_node("Ground");

@onready var bgChars:AnimatedSprite2D = get_node("BGChars");

@onready var gf:AnimatedSprite2D = get_node("GF/AnimatedSprite2D");
@onready var bf:AnimatedSprite2D = get_node("BF/AnimatedSprite2D");
@onready var enemy:AnimatedSprite2D = get_node("RobTop/AnimatedSprite2D");

@onready var fgChars:AnimatedSprite2D = get_node("FGChars");

var camPos:Vector2 = Vector2.ZERO;

var curEnemyKey:int = 0;

var isRight:bool = false;

var bfIdle:bool = true;
var bfHold:bool = false;
var bfHoldKey:int = -1;
var bfMissing:bool = false;

var enmIdle:bool = true;
var enmHold:bool = false;
var enmHoldKey:int = -1;

var keyMap:Array = ["left", "down", "up", "right", "leftAlt", "downAlt", "upAlt", "rightAlt"];

var animMultiplier:float = 1;
var speedScale:float = 0;

func col(col:Color):
	bg.modulate = col;
	gnd.modulate = col;

func _ready():
	camPos = cam.get_screen_center_position();
	bg.modulate = Color8(35, 65, 255, 255);
	bg.scrollFactor = Vector2(0.9, 1);
	bg.basePosition = camPos;
	gnd.modulate = Color8(0, 16, 163, 255);
	cam.zoom = Vector2.ONE * 1.2;
	bgChars.play("idle");
	bf.play("idle");
	enemy.play("idle");
	fgChars.play("idle");
	fgChars.scrollFactor = Vector2(1.15, 1);
	fgChars.basePosition = camPos;
	speedScale = BeatHandler.bpm / (90.0 / animMultiplier);
	bgChars.speed_scale = speedScale;
	fgChars.speed_scale = speedScale;
	pass;

func _process(delta):
	if (bf.animation == "idle"):
		if (bf.speed_scale != speedScale):
			bf.speed_scale = speedScale;
	else:
		if (bf.speed_scale != 1):
			bf.speed_scale = 1;
	if (enemy.animation == "idle"):
		if (enemy.speed_scale != speedScale):
			enemy.speed_scale = speedScale;
	else:
		if (enemy.speed_scale != speedScale):
			enemy.speed_scale = 1;
	
	camPos = cam.get_screen_center_position();
	
	bg.curPosition = camPos;
	fgChars.curPosition = camPos;
	
	if (bfHold && keyMap.has(bf.animation) && bf.frame > 1):
		bf.frame = 0;
	
	if ((bfIdle || !bfHold) && bf.animation != "idle" && bf.frame + 1 >= bf.sprite_frames.get_frame_count(bf.animation)):
		bf.play("idle");
		bf.frame = 0;
	
	if (enmHold && keyMap.has(enemy.animation) && enemy.frame > 1):
		enemy.frame = 0;
	
	if ((enmIdle || !enmHold) && enemy.animation != "idle" && enemy.frame + 1 >= enemy.sprite_frames.get_frame_count(enemy.animation)):
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
		bgChars.frame = 0;
		if (bf.animation == "idle"):
			bf.frame = 0;
		if (enemy.animation == "idle"):
			enemy.frame = 0;
		fgChars.frame = 0;
	isRight = !isRight;
	pass;

func bfNormal():
	bfIdle = true;
	bfHold = false;
	bfHoldKey = -1;
	pass;

func bfConfirmLoop(hk:int, alt:bool):
	bfIdle = false;
	bfHold = true;
	if (alt):
		hk += 4;
	bfHoldKey = hk;
	bf.play(keyMap[bfHoldKey]);
	pass;

func bfConfirm(hk:int, alt:bool):
	bfIdle = false;
	bfHold = false;
	bfHoldKey = -1;
	if (alt):
		hk += 4;
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

func enmConfirmLoop(hk:int, alt:bool):
	enmIdle = false;
	enmHold = true;
	if (alt):
		hk += 4;
	enmHoldKey = hk;
	enemy.play(keyMap[enmHoldKey]);
	pass;

func enmConfirm(hk:int, alt:bool):
	enmIdle = false;
	enmHold = false;
	enmHoldKey = -1;
	if (alt):
		hk += 4;
	enemy.play(keyMap[hk]);
	enemy.frame = 0;
	pass;

func focus(mustHitSection:bool):
	if (!mustHitSection):
		cam.position.x = enemy.get_parent().position.x;
	else:
		cam.position.x = bf.get_parent().position.x;
	pass;
