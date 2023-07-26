extends Node2D

@onready var canvas = get_node("Canvas");
@onready var pauseScreen = canvas.get_node("PauseScreen");
@onready var label = pauseScreen.get_node("Label");

var labelBase:String = "GAME PAUSED";
var labelList:PackedStringArray = [];

var tweener:CustomFloatTweener;
var easeTime:float = 0.5;

func randomizeLabelText():
	label.text = labelBase + "\n\n" + labelList[randi() % labelList.size()];

func _notification(what):
	match (what):
		MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT:
			get_tree().paused = true;
			if (tweener.inverted):
				tweener._target = 1;
				tweener.play();
			randomizeLabelText();
		MainLoop.NOTIFICATION_APPLICATION_FOCUS_IN:
			get_tree().paused = false;
			if (!tweener.inverted):
				tweener._target = tweener.current();
				tweener.play_invert();

func _ready():
	labelList = Assets.getText("pauseScreen", false, true).split("\n\n");
	tweener = CustomFloatTweener.new(0, 0, easeTime, Tween.TRANS_EXPO, Tween.EASE_OUT, Tween.TWEEN_PAUSE_PROCESS);
	tweener.inverted = true;
	add_child(tweener);
	pass

func _process(delta):
	var alpha:float = tweener.current();
	pauseScreen.modulate.a = alpha;
	if (alpha <= 0):
		canvas.layer = -128;
		return;
	canvas.layer = 128;
	pass
