extends Node2D

signal finishedStats();

@onready var gLabelPre:Label = get_node("GLabelPre");
@onready var gLabel:Label = get_node("GLabel");
@onready var sLabel:Label = get_node("SLabel");
@onready var mLabel:Label = get_node("MLabel");
@onready var aLabel:Label = get_node("ALabel");
@onready var cLabel:Label = get_node("CLabel");
@onready var enter:Label = get_node("Enter");
@onready var scaryOverlay:ColorRect = get_node("ScaryOverlay");
var tween:Tween;
@onready var timer:Timer = get_node("Timer");
@onready var procTim:Timer = get_node("ProcTim");

var curLabel:int = 0;

var score:int = 0;
var misses:int = 0;
var accuracy:float = 0;
var coins:int = 0;

var curScore:int = 0;
var curMisses:int = 0;
var curAccuracy:float = 0;
var curCoins:int = 0;

var grade:int = 0;
var hue:float = 0;
var animSpeed:float = 0.25;
var gradeMap:Array = ["S", "A", "B", "C", "D", "F"];
var colorProc:bool = false;
var initialized:bool = false;

func init(s:int, m:int, a:float, c:int):
	score = s;
	misses = m;
	accuracy = a;
	coins = c;
	for i in range(Data.gradeAcc.size()):
		if (accuracy >= Data.gradeAcc[i]):
			if (i == 0 && misses > 0):
				continue;
			grade = i;
			break;
	initialized = true;
	timer.start(animSpeed + 0.75);
	pass;

var tweenDone:bool = true;

func finishedTween():
	tweenDone = true;

func refreshTween():
	if (tweenDone):
		tweenDone = false;
		if (tween):
			tween.finished.disconnect(Callable(self, "finishedTween"));
			tween.kill();
		tween = get_tree().create_tween().set_parallel(true);
		tween.finished.connect(Callable(self, "finishedTween"));

func callFinishedStats():
#	tween.interpolate_property(enter, "modulate", Color8(255, 255, 255, 0), Color8(255, 255, 255, 255), 0.5, Tween.TRANS_SINE, Tween.EASE_IN);
#	tween.start();
	refreshTween();
	enter.modulate = Color(1, 1, 1, 0);
	tween.tween_property(enter, "modulate:a", 1, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN);
	emit_signal("finishedStats");
	pass;

func processLabels():
	var fas:float = animSpeed / 4;
	match (curLabel):
		0:
#			tween.interpolate_property(self, "curScore", 0, score, animSpeed, Tween.TRANS_SINE, Tween.EASE_IN);
#			tween.start();
			
#			tween.interpolate_property(sLabel, "modulate", Color8(255, 255, 255, 255), Color8(255, 255, 255, 0), animSpeed / 4, Tween.TRANS_SINE, Tween.EASE_IN);
#			tween.start();
#			tween.interpolate_property(sLabel, "modulate", Color8(255, 255, 255, 0), Color8(255, 255, 255, 255), animSpeed / 4, Tween.TRANS_SINE, Tween.EASE_IN, animSpeed / 4);
#			tween.start();
#			tween.interpolate_property(sLabel, "modulate", Color8(255, 255, 255, 255), Color8(255, 255, 255, 0), animSpeed / 4, Tween.TRANS_SINE, Tween.EASE_IN, (animSpeed / 4) * 2);
#			tween.start();
#			tween.interpolate_property(sLabel, "modulate", Color8(255, 255, 255, 0), Color8(255, 255, 255, 255), animSpeed / 4, Tween.TRANS_SINE, Tween.EASE_IN, (animSpeed / 4) * 3);
#			tween.start();

			refreshTween();
			curScore = 0;
			tween.tween_property(self, "curScore", score, animSpeed).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN);
			sLabel.modulate = Color(1, 1, 1, 1);
			tween.tween_property(sLabel, "modulate:a8", 0, fas).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN);
			tween.tween_property(sLabel, "modulate:a8", 255, fas).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN).set_delay(fas);
			tween.tween_property(sLabel, "modulate:a8", 0, fas).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN).set_delay(fas * 2);
			tween.tween_property(sLabel, "modulate:a8", 255, fas).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN).set_delay(fas * 3);
			
			Sound.play("confirmMenu").pitch_scale = 0.65;
		1:
#			tween.interpolate_property(self, "curMisses", 0, misses, animSpeed, Tween.TRANS_SINE, Tween.EASE_IN);
#			tween.start();
			
#			tween.interpolate_property(mLabel, "modulate", Color8(255, 255, 255, 255), Color8(255, 255, 255, 0), animSpeed / 4, Tween.TRANS_SINE, Tween.EASE_IN);
#			tween.start();
#			tween.interpolate_property(mLabel, "modulate", Color8(255, 255, 255, 0), Color8(255, 255, 255, 255), animSpeed / 4, Tween.TRANS_SINE, Tween.EASE_IN, animSpeed / 4);
#			tween.start();
#			tween.interpolate_property(mLabel, "modulate", Color8(255, 255, 255, 255), Color8(255, 255, 255, 0), animSpeed / 4, Tween.TRANS_SINE, Tween.EASE_IN, (animSpeed / 4) * 2);
#			tween.start();
#			tween.interpolate_property(mLabel, "modulate", Color8(255, 255, 255, 0), Color8(255, 255, 255, 255), animSpeed / 4, Tween.TRANS_SINE, Tween.EASE_IN, (animSpeed / 4) * 3);
#			tween.start();

			refreshTween();
			curMisses = 0;
			tween.tween_property(self, "curMisses", misses, animSpeed).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN);
			mLabel.modulate = Color(1, 1, 1, 1);
			tween.tween_property(mLabel, "modulate:a8", 0, fas).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN);
			tween.tween_property(mLabel, "modulate:a8", 255, fas).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN).set_delay(fas);
			tween.tween_property(mLabel, "modulate:a8", 0, fas).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN).set_delay(fas * 2);
			tween.tween_property(mLabel, "modulate:a8", 255, fas).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN).set_delay(fas * 3);
			
			Sound.play("confirmMenu").pitch_scale = 0.75;
		2:
#			tween.interpolate_property(self, "curAccuracy", 0, accuracy, animSpeed, Tween.TRANS_SINE, Tween.EASE_IN);
#			tween.start();
			
#			tween.interpolate_property(aLabel, "modulate", Color8(255, 255, 255, 255), Color8(255, 255, 255, 0), animSpeed / 4, Tween.TRANS_SINE, Tween.EASE_IN);
#			tween.start();
#			tween.interpolate_property(aLabel, "modulate", Color8(255, 255, 255, 0), Color8(255, 255, 255, 255), animSpeed / 4, Tween.TRANS_SINE, Tween.EASE_IN, animSpeed / 4);
#			tween.start();
#			tween.interpolate_property(aLabel, "modulate", Color8(255, 255, 255, 255), Color8(255, 255, 255, 0), animSpeed / 4, Tween.TRANS_SINE, Tween.EASE_IN, (animSpeed / 4) * 2);
#			tween.start();
#			tween.interpolate_property(aLabel, "modulate", Color8(255, 255, 255, 0), Color8(255, 255, 255, 255), animSpeed / 4, Tween.TRANS_SINE, Tween.EASE_IN, (animSpeed / 4) * 3);
#			tween.start();

			refreshTween();
			curAccuracy = 0;
			tween.tween_property(self, "curAccuracy", accuracy, animSpeed).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN);
			aLabel.modulate = Color(1, 1, 1, 1);
			tween.tween_property(aLabel, "modulate:a8", 0, fas).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN);
			tween.tween_property(aLabel, "modulate:a8", 255, fas).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN).set_delay(fas);
			tween.tween_property(aLabel, "modulate:a8", 0, fas).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN).set_delay(fas * 2);
			tween.tween_property(aLabel, "modulate:a8", 255, fas).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN).set_delay(fas * 3);
			
			Sound.play("confirmMenu").pitch_scale = 0.8;
		3:
#			tween.interpolate_property(self, "curCoins", 0, coins, animSpeed, Tween.TRANS_SINE, Tween.EASE_IN);
#			tween.start();
			
#			tween.interpolate_property(cLabel, "modulate", Color8(255, 255, 255, 255), Color8(255, 255, 255, 0), animSpeed / 4, Tween.TRANS_SINE, Tween.EASE_IN);
#			tween.start();
#			tween.interpolate_property(cLabel, "modulate", Color8(255, 255, 255, 0), Color8(255, 255, 255, 255), animSpeed / 4, Tween.TRANS_SINE, Tween.EASE_IN, animSpeed / 4);
#			tween.start();
#			tween.interpolate_property(cLabel, "modulate", Color8(255, 255, 255, 255), Color8(255, 255, 255, 0), animSpeed / 4, Tween.TRANS_SINE, Tween.EASE_IN, (animSpeed / 4) * 2);
#			tween.start();
#			tween.interpolate_property(cLabel, "modulate", Color8(255, 255, 255, 0), Color8(255, 255, 255, 255), animSpeed / 4, Tween.TRANS_SINE, Tween.EASE_IN, (animSpeed / 4) * 3);
#			tween.start();

			refreshTween();
			curCoins = 0;
			tween.tween_property(self, "curCoins", coins, animSpeed).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN);
			cLabel.modulate = Color(1, 1, 1, 1);
			tween.tween_property(cLabel, "modulate:a8", 0, fas).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN);
			tween.tween_property(cLabel, "modulate:a8", 255, fas).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN).set_delay(fas);
			tween.tween_property(cLabel, "modulate:a8", 0, fas).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN).set_delay(fas * 2);
			tween.tween_property(cLabel, "modulate:a8", 255, fas).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN).set_delay(fas * 3);
			
			Sound.play("confirmMenu").pitch_scale = 0.9;
		4:
			gLabel.visible = true;
			colorProc = true;
			if (grade != 5):
#				tween.interpolate_property(gLabelPre, "modulate", Color8(255, 255, 255, 255), Color8(255, 255, 255, 0), animSpeed / 4, Tween.TRANS_SINE, Tween.EASE_IN);
#				tween.start();
#				tween.interpolate_property(gLabelPre, "modulate", Color8(255, 255, 255, 0), Color8(255, 255, 255, 255), animSpeed / 4, Tween.TRANS_SINE, Tween.EASE_IN, animSpeed / 4);
#				tween.start();
#				tween.interpolate_property(gLabelPre, "modulate", Color8(255, 255, 255, 255), Color8(255, 255, 255, 0), animSpeed / 4, Tween.TRANS_SINE, Tween.EASE_IN, (animSpeed / 4) * 2);
#				tween.start();
#				tween.interpolate_property(gLabelPre, "modulate", Color8(255, 255, 255, 0), Color8(255, 255, 255, 255), animSpeed / 4, Tween.TRANS_SINE, Tween.EASE_IN, (animSpeed / 4) * 3);
#				tween.start();
				
#				tween.interpolate_property(gLabel, "modulate", Color8(255, 255, 255, 255), Color8(255, 255, 255, 0), animSpeed / 4, Tween.TRANS_SINE, Tween.EASE_IN);
#				tween.start();
#				tween.interpolate_property(gLabel, "modulate", Color8(255, 255, 255, 0), Color8(255, 255, 255, 255), animSpeed / 4, Tween.TRANS_SINE, Tween.EASE_IN, animSpeed / 4);
#				tween.start();
#				tween.interpolate_property(gLabel, "modulate", Color8(255, 255, 255, 255), Color8(255, 255, 255, 0), animSpeed / 4, Tween.TRANS_SINE, Tween.EASE_IN, (animSpeed / 4) * 2);
#				tween.start();
#				tween.interpolate_property(gLabel, "modulate", Color8(255, 255, 255, 0), Color8(255, 255, 255, 255), animSpeed / 4, Tween.TRANS_SINE, Tween.EASE_IN, (animSpeed / 4) * 3);
#				tween.start();

				refreshTween();
				
				gLabelPre.modulate = Color(1, 1, 1, 1);
				tween.tween_property(gLabelPre, "modulate:a8", 0, fas).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN);
				tween.tween_property(gLabelPre, "modulate:a8", 255, fas).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN).set_delay(fas);
				tween.tween_property(gLabelPre, "modulate:a8", 0, fas).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN).set_delay(fas * 2);
				tween.tween_property(gLabelPre, "modulate:a8", 255, fas).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN).set_delay(fas * 3);
				
				gLabel.modulate = Color(1, 1, 1, 1);
				tween.tween_property(gLabel, "modulate:a8", 0, fas).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN);
				tween.tween_property(gLabel, "modulate:a8", 255, fas).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN).set_delay(fas);
				tween.tween_property(gLabel, "modulate:a8", 0, fas).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN).set_delay(fas * 2);
				tween.tween_property(gLabel, "modulate:a8", 255, fas).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN).set_delay(fas * 3);
			match (grade):
				0:
					Sound.play("confirmMenu").pitch_scale = 1.05;
				1:
					Sound.play("confirmMenu");
				2:
					Sound.play("confirmMenu").pitch_scale = 0.85;
				3:
					Sound.play("confirmMenu").pitch_scale = 0.7;
				4:
					Sound.play("confirmMenu").pitch_scale = 0.6;
				5:
#					tween.interpolate_property(scaryOverlay, "modulate", Color8(0, 0, 0, 0), Color8(0, 0, 0, 128), 2, Tween.TRANS_SINE, Tween.EASE_IN);
#					tween.start();
					refreshTween();
					scaryOverlay.modulate = Color(0, 0, 0, 0);
					tween.tween_property(scaryOverlay, "modulate:a8", 128, 2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN);
					Sound.play("confirmMenu").pitch_scale = 0.2;
	curLabel += 1;
	if (curLabel > 4):
		procTim.start(4);
		timer.stop();
	pass;

func _ready():
	gLabel.visible = false;
	timer.connect("timeout", Callable(self, "processLabels"));
	procTim.connect("timeout", Callable(self, "callFinishedStats"));
	# init(100, 0, 100.0, 2);
	pass;

func _process(delta):
	gLabel.text = gradeMap[grade];
	match (grade):
		0:
			gLabel.add_theme_color_override("font_outline_color", Data.ColorHSV(hue, 64, 100).rgb);
		1:
			grade = 1;
		5:
			gLabel.add_theme_color_override("font_outline_color", Color.GRAY);
		_:
			gLabel.add_theme_color_override("font_outline_color", Color.GREEN);
	sLabel.text = "Score:" + str(curScore);
	mLabel.text = "Misses:" + str(curMisses);
	curAccuracy = snapped(curAccuracy, 0.01);
	aLabel.text = "Accuracy:" + str(curAccuracy).pad_decimals(2) + "%";
	cLabel.text = "Coins:" + str(curCoins);
	if (colorProc):
		hue += delta * 45;
		if (hue > 360):
			hue -= 360;
	pass;
