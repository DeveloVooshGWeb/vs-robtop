@tool
extends AnimatedSprite2D

@export var character:String = "BF": set = setChar;
var loaded:String = "";

func setChar(val):
	character = val;
	sprite_frames = load("res://assets/res/healthIcons/" + character + ".res");
	loaded = "" + character;
	play("0");
	hide();
	show();

func _ready():
	pass;
