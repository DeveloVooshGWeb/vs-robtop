extends Node2D

onready var canvas = get_node("Canvas");
onready var pauseScreen = canvas.get_node("PauseScreen");
onready var label = pauseScreen.get_node("Label");

var labelBase:String = "GAME PAUSED";
var labelList:PoolStringArray = [];

var easeName:String = "PauseAlpha";
var easeTime:float = 0.5;

func randomizeLabelText():
	label.text = labelBase + "\n\n" + labelList[randi() % labelList.size()];

func _notification(what):
	match (what):
		MainLoop.NOTIFICATION_WM_FOCUS_OUT:
			get_tree().paused = true;
			EaseHandler.setEase(easeName, 0, 1, easeTime, "Expo", "EaseOut", true);
			EaseHandler.playEase(easeName);
			randomizeLabelText();
		MainLoop.NOTIFICATION_WM_FOCUS_IN:
			get_tree().paused = false;
			EaseHandler.setV2(easeName, EaseHandler.getEase(easeName));
			EaseHandler.playEase(easeName, true);

func _ready():
	labelList = Assets.getText("pauseScreen", false, true).split("\n\n");
	pass

func _process(delta):
	var alpha:float = EaseHandler.getEase(easeName);
	pauseScreen.modulate.a = alpha;
	if (alpha <= 0):
		canvas.layer = -128;
		return;
	canvas.layer = 128;
	pass
