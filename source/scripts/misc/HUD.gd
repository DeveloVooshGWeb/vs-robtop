extends Node2D

@onready var dispText:Label = get_node("DisplayText");

var dispScore:String = "0";
var dispMisses:String = "0";
var dispHealth:String = "50%";
var dispAccuracy:String = "100%";

func updScore(score:int):
	dispScore = str(score);
	dispText.text = "Score: " + dispScore + " | Misses: " + dispMisses + " | Health: " + dispHealth + " | Accuracy: " + dispAccuracy;
	pass;

func updMisses(misses:int):
	dispMisses = str(misses);
	dispText.text = "Score: " + dispScore + " | Misses: " + dispMisses + " | Health: " + dispHealth + " | Accuracy: " + dispAccuracy;
	pass;

func updHealth(health:float):
	dispHealth = str(floor((health / 2.0) * 100)) + "%";
	dispText.text = "Score: " + dispScore + " | Misses: " + dispMisses + " | Health: " + dispHealth + " | Accuracy: " + dispAccuracy;
	pass;

func updAccuracy(accuracy:float):
	dispAccuracy = str(accuracy).pad_decimals(2) + "%";
	dispText.text = "Score:" + dispScore + " | Misses:" + dispMisses + " | Health:" + dispHealth + " | Accuracy:" + dispAccuracy;
	pass;

func _ready():
	pass;
