tool
extends Node2D

signal pressed();

onready var btn:Button = get_node("Button");
onready var btnText:Label = btn.get_node("BtnText");
onready var anim:AnimationPlayer = get_node("Anim");

export(String) var content:String = "Content" setget setContent;

func setContent(val):
	content = val;
	hide();
	show();

func btnPressed():
	btn.release_focus();
	emit_signal("pressed");

func updateValues():
	btnText.text = content;

func button_down():
	Data.disableInput = true;
	anim.play("Down");

func button_up():
	Data.disableInput = false;
	anim.play("Up");

func _ready():
	btn.connect("pressed", self, "btnPressed");
	btn.connect("button_down", self, "button_down");
	btn.connect("button_up", self, "button_up");
	updateValues();
	pass;

func _draw():
	if (Engine.editor_hint):
		if (!btn):
			btn = get_node("Button");
		if (!btnText):
			btnText = btn.get_node("BtnText");
		updateValues();
	pass;