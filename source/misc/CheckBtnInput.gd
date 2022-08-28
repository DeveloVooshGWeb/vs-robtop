tool
extends Node2D

signal toggled(checked);

onready var btn:CheckButton = get_node("Btn");
onready var slider:Node2D = btn.get_node("Slider");
onready var anim:AnimationPlayer = get_node("Anim");

var btnOffset:float = 64;

export(String) var key:String = "Key" setget setKey;

func _fixData():
	btn.text = key + ":";
	btn.rect_size.x = 0;
	slider.position.x = btn.rect_size.x - btnOffset;
	btn.rect_size.x = slider.position.x + 96;

func changed(checked:bool):
	btn.release_focus();
	emit_signal("toggled", checked);
	if (checked):
		anim.play("On");
		return;
	anim.play("Off");

func _ready():
	_fixData();
	btn.connect("toggled", self, "changed");
	pass;

func _draw():
	if (Engine.editor_hint):
		if (!btn):
			btn = get_node("Btn");
		if (!slider):
			slider = btn.get_node("Slider");
		_fixData();

func setKey(val):
	key = val;
	refresh();

func refresh():
	hide();
	show();
