extends LineEdit;

onready var output:Label = get_node("Output");
var colorData:Array = [Color8(107, 153, 214, 255), Color8(255, 255, 255, 255)];
var maxChars:int = 14;

func _ready():
	InputHandler.connect("globalMouseUp", self, "clicked");
	pass;

func clicked(index, pos):
	if (index == 1 && !Utils.collide(pos, Vector2.ZERO, rect_position + (rect_size / Vector2(2, 2)), rect_size)):
			release_focus();

func _process(delta):
	if (text.strip_edges().length() <= 0):
		text = "";
		output.text = "...";
		output.modulate = colorData[0];
	else:
		if (text.length() > maxChars):
			text = text.substr(0, maxChars);
		output.text = text;
		output.modulate = colorData[1];
	pass;
