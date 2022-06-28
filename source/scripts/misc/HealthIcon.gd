tool
extends AnimatedSprite

export(String) var character:String = "BF" setget setChar;
var loaded:String = "";

func setChar(val):
	character = val;
	frames = load("res://assets/res/healthIcons/" + character + ".res");
	loaded = "" + character;
	play("0");
	hide();
	show();

func _ready():
	pass;
