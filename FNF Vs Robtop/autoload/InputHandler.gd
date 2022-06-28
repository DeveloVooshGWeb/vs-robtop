extends Node

signal justPressed(key);
signal pressed(key);
signal justReleased(key);

signal mouseDoubleClick(index, pos);
signal mouseDown(index, pos);
signal mouseUp(index, pos);
signal mouseDrag(index, pos);
signal mouseMove(pos);
signal mouseScroll(index);

signal globalMouseDown(index, pos);
signal globalMouseUp(index, pos);
signal globalMouseMove(pos);

var keys:Array = [];
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
			var key:String = OS.get_scancode_string(evt.get_scancode_with_modifiers());
			if (evt.pressed):
				if (!keys.has(key)):
					emit_signal("justPressed", key);
					keys.append(key);
				return;
			if (keys.has(key)):
				emit_signal("justReleased", key);
				keys.remove(keys.find(key));
		elif (evt is InputEventMouseButton):
			var pressed:bool = evt.pressed;
			var index:int = evt.button_index;
			index -= 1;
			var scrollStuff:int = index - 3;
			if (index in range(3)):
				var pos:Vector2 = evt.position;
				held[index] = pressed;
				index += 1;
				match (pressed):
					true:
						if (evt.doubleclick):
							emit_signal("mouseDoubleClick", index, pos);
						emit_signal("mouseDown", index, pos);
						emit_signal("globalMouseDown", index, pos);
						emit_signal("mouseDrag", index, pos);
					false:
						emit_signal("mouseUp", index, pos);
						emit_signal("globalMouseUp", index, pos);
			elif (scrollStuff in range(2)):
				emit_signal("mouseScroll", scrollStuff);
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
			var pressed:bool = evt.pressed;
			var index:int = evt.button_index;
			index -= 1;
			if (index in range(3)):
				var pos:Vector2 = evt.position;
				held[index] = pressed;
				index += 1;
				match (pressed):
					true:
						emit_signal("globalMouseDown", index, pos);
					false:
						emit_signal("globalMouseUp", index, pos);
	pass;
