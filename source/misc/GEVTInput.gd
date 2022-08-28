extends Node2D

signal changed(txt);
signal unfocused();

onready var input:TextEdit = get_node("GEVTField");

func text_changed():
	emit_signal("changed", input.text);

func focus_entered():
	Data.disableInput = true;

func focus_exited():
	emit_signal("unfocused");
	Data.disableInput = false;

func clicked(index, pos):
	if (index == 1 && !Utils.collide(pos, Vector2.ZERO, position + (input.rect_size / Vector2(2, 2)), input.rect_size)):
			input.release_focus();

func _ready():
	InputHandler.connect("globalMouseUp", self, "clicked");
	input.connect("focus_entered", self, "focus_entered");
	input.connect("focus_exited", self, "focus_exited");
	input.connect("text_changed", self, "text_changed");
	pass;
