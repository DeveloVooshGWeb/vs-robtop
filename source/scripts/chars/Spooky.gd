extends Node2D

onready var spr:AnimatedSprite = get_node("AnimatedSprite");
var faces:Array = ["4k", "bozo", "disappoint", "ew", "gloat", "regular", "sadge", "sleep", "surprise", "sus1", "sus2", "sus3", "talk"];
var size:Vector2 = Vector2.ZERO;

func play(face:String = ""):
	var index:int = faces.find(face);
	if (index < 0):
		spr.frame = 5;
		return;
	spr.frame = index;
	updateSize();

func updateSize():
	size = spr.frames.get_frame(spr.animation, spr.frame).get_size() * scale;

func _ready():
	updateSize();
	pass;