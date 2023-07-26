extends LineEdit;

@onready var output:Label = get_node("Output");
var colorData:Array = [Color8(107, 153, 214, 255), Color8(255, 255, 255, 255)];

var initPos:Vector2 = Vector2.ZERO;
var initSize:Vector2 = Vector2.ZERO;

func _ready():
	InputHandler.connect("globalMouseUp", Callable(self, "clicked"));
	initPos += position;
	initSize += size;
	text_changed.connect(Callable(self, "tc"));
	pass;

func clicked(index, pos):
	if (index == 1 && !Utils.collide(pos, Vector2.ZERO, position + (size / Vector2(2, 2)), size)):
			release_focus();

func tc(_nt:String):
	var calcScale:float = (output.get_theme_default_font().get_string_size(output.text.substr(0, 15)).x / output.get_theme_default_font().get_string_size(output.text).x);
	scale = Vector2(calcScale, calcScale);
	size = initSize / scale.x;
	output.size = size;
#	output.position = (output.size - output.size * calcScale);

func _process(delta):
	if (text.strip_edges().length() <= 0):
		text = "";
		output.text = "...";
		output.modulate = colorData[0];
	else:
		output.text = text;
		output.modulate = colorData[1];
	pass;
