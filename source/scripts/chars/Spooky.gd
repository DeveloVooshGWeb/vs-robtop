extends Node2D

var faces:Array = ["4k", "bozo", "disappoint", "ew", "gloat", "regular", "sadge", "sleep", "surprise", "sus1", "sus2", "sus3", "talk"];

func play(face:String = ""):
	var index:int = faces.find(face);
	if (index < 0):
		$AnimatedSprite.frame = 5;
		return;
	$AnimatedSprite.frame = index;

func _ready():
	pass
