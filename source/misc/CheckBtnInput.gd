@tool
extends Node2D

signal toggled(checked);

@onready var btn:CheckButton = get_node("Btn");
@onready var slider:Node2D = btn.get_node("Slider");
@onready var anim:AnimationPlayer = get_node("Anim");

var btnOffset:float = 32;

@export var key:String = "Key": set = setKey

func _fixData():
	btn.text = key + ":";
#	btn.size.x = 0;
#	btn.anchor_left = 0;
#	btn.anchor_top = -24;
#	btn.anchor_right = 166;
#	btn.anchor_bottom = 24;
#	btn.size = Vector2(166, 48);
	btn.size.x = 0;
#	slider.position.x = load("res://assets/fonts/montserrat/Montserrat-Regular.ttf").get_string_size(btn.text, 0, -1, 32).x * 2 + btn.text.length() * 2 - btnOffset;
	slider.position.x = btn.size.x - btnOffset;
	btn.size.x = slider.position.x + 96;

func changed(checked:bool):
	btn.release_focus();
	emit_signal("toggled", checked);
	if (checked):
		anim.play("On");
		return;
	anim.play("Off");

func _ready():
	_fixData();
	btn.connect("toggled", Callable(self, "changed"));
	pass;

func _draw():
	if (Engine.is_editor_hint()):
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
