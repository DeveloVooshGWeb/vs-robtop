extends Node

# Hey! Guess Makes This Code Funnier?
# I Made It So That Everything Would Be Ease-ier HAHAHHA
# I Need To Stop Making Horrible Jokes

@onready var Easing = preload("res://Easing/Easing.gd");

var easeList:Dictionary = {};

func clear():
	easeList.is_empty();

func setEase(easeId:String = "", v1:float = 0, v2:float = 0, secs:float = 0, transitionType:String = "Linear", easeType:String = "EaseNone", unpausable:bool = false):
	var easeData:Dictionary = { "data": Vector3(v1, v2, secs), "current": Vector2(v2, v1), "elapsed": 0.0, "value": v1, "transition": transitionType, "type": easeType, "unpausable": unpausable, "playing": false };
	easeList[easeId] = easeData;

func setV1(easeId:String, v:float):
	if (!easeList.has(easeId)):
		return;
	easeList[easeId].data.x = v;
	easeList[easeId].current.x = v;

func setV2(easeId:String, v:float):
	if (!easeList.has(easeId)):
		return;
	easeList[easeId].data.y = v;
	easeList[easeId].current.y = v;

func getEase(easeId:String = "") -> float:
	if (!easeList.has(easeId)):
		return 0.0;
	return easeList[easeId].value;

func restartEase(easeId:String):
	if (!easeList.has(easeId)):
		return;
	easeList[easeId].elapsed = 0.0;

func pauseEase(easeId:String = ""):
	easeList[easeId].playing = false;

func playEase(easeId:String = "", invert:bool = false):
	if (!easeList.has(easeId)):
		return;
	var prevCurrent:Vector2 = easeList[easeId].current;
	if (invert):
		easeList[easeId].current = Vector2(easeList[easeId].data.y, easeList[easeId].data.x);
	else:
		easeList[easeId].current = Vector2(easeList[easeId].data.x, easeList[easeId].data.y);
	if (easeList[easeId].current != prevCurrent):
		# if (!easeList[easeId].playing):
		restartEase(easeId);
		easeList[easeId].playing = true;
		# else:
			# easeList[easeId].elapsed = easeList[easeId].data.z - easeList[easeId].elapsed;

func _ready():
#	SceneTransition.connect("changingScene", self, "clear");
	pass;

func _process(delta):
	for easeId in easeList.keys():
		if (easeList[easeId].playing && (!get_tree().paused || (get_tree().paused && easeList[easeId].unpausable))):
				easeList[easeId].value = (Easing[easeList[easeId].transition].call(easeList[easeId].type, easeList[easeId].elapsed, 0, 1, easeList[easeId].data.z) * (easeList[easeId].current.y - easeList[easeId].current.x)) + easeList[easeId].current.x;
				easeList[easeId].elapsed += delta;
				if (easeList[easeId].elapsed > easeList[easeId].data.z):
					easeList[easeId].elapsed = easeList[easeId].data.z;
					pauseEase(easeId);
	pass;
