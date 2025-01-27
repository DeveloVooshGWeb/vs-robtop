extends Node

signal justPressed(key);
signal pressed(key);
signal justReleased(key);

signal mouseDoubleClick(index, pos);
signal mouseDown(index, pos);
signal mouseUp(index, pos);
signal mouseDrag(index, pos);
signal mouseScroll(index, pos);
signal mouseMove(pos);

signal globalMouseDown(index, pos);
signal globalMouseUp(index, pos);
signal globalMouseMove(pos);

var keys:Array[Key] = [];
var held:Array = [false, false, false];

func _ready():
	pass

func _process(delta):
	if (!Data.disableInput):
		for key in keys:
			emit_signal("pressed", key);
	pass;

func _input(evt):
	if (!Data.disableInput):
		if (evt is InputEventKey):
			var key:Key = evt.keycode;
			if (evt.pressed):
				if (!keys.has(key)):
					emit_signal("justPressed", key);
					keys.append(key);
				return;
			if (keys.has(key)):
				emit_signal("justReleased", key);
				keys.erase(key);
		elif (evt is InputEventMouseButton):
			var pressedB:bool = evt.pressed;
			var index:int = evt.button_index;
			index -= 1;
			var scrollStuff:int = index - 3;
			var pos:Vector2 = evt.position;
			if (index in range(3)):
				held[index] = pressedB;
				index += 1;
				match (pressedB):
					true:
						if (evt.double_click):
							emit_signal("mouseDoubleClick", index, pos);
						emit_signal("mouseDown", index, pos);
						emit_signal("globalMouseDown", index, pos);
						emit_signal("mouseDrag", index, pos);
					false:
						emit_signal("mouseUp", index, pos);
						emit_signal("globalMouseUp", index, pos);
			elif (scrollStuff in range(2)):
				emit_signal("mouseScroll", scrollStuff, pos);
		elif (evt is InputEventMouseMotion):
			emit_signal("mouseMove", evt.position);
			emit_signal("globalMouseMove", evt.position);
			for i in range(held.size()):
				var index:int = i;
				if (held[index]):
					index += 1;
					emit_signal("mouseDrag", index, evt.position);
	else:
		if (evt is InputEventMouseButton):
			var pressedB:bool = evt.pressed;
			var index:int = evt.button_index;
			index -= 1;
			if (index in range(3)):
				var pos:Vector2 = evt.position;
				held[index] = pressedB;
				index += 1;
				match (pressedB):
					true:
						emit_signal("globalMouseDown", index, pos);
					false:
						emit_signal("globalMouseUp", index, pos);
	pass;
