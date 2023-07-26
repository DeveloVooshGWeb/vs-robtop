extends Node2D

signal changed(txt);
signal unfocused();

@onready var input:CodeEdit = get_node("GEVTField");

func text_changed():
	emit_signal("changed", input.text);

func focus_entered():
	Data.disableInput = true;

func focus_exited():
	emit_signal("unfocused");
	Data.disableInput = false;

func clicked(index, pos):
	if (index == 1 && !Utils.collide(pos, Vector2.ZERO, position + (input.size / Vector2(2, 2)), input.size)):
			input.release_focus();

func _ready():
	InputHandler.connect("globalMouseUp", Callable(self, "clicked"));
	input.connect("focus_entered", Callable(self, "focus_entered"));
	input.connect("focus_exited", Callable(self, "focus_exited"));
	input.connect("text_changed", Callable(self, "text_changed"));
	pass;
