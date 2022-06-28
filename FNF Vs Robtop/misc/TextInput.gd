tool
extends Node2D

signal entered(data);

onready var label:Label = get_node("Key");
onready var input:LineEdit = get_node("TextField");
onready var highlighter:ColorRect = get_node("Highlighter");

export(String) var key:String = "Key" setget setKey;
export(String) var placeholder:String = "Placeholder" setget setPH;
export(String) var defaultValue:String = "" setget setDV;
export(float) var leftSpacing:float = 256.0 setget setLeftSpacing;
export(float) var rightSpacing:float = 256.0 setget setRightSpacing;
export(float) var highlightSpeed:float = 0.3 setget setHS;
var tweenType:int = Tween.TRANS_SINE;
var easeType:int = Tween.EASE_OUT;
var defaultData:Dictionary = {};
var data:Dictionary = {
	"str": {
		"normal": "",
		"trimmed": ""
	},
	"float": 0.0,
	"int": {
		"normal": 0,
		"rounded": 0
	},
	"json": {
		"dictionary": {},
		"array": []
	}
};

var saved:Color = Color.white;
#var unsaved:Color = Color8(39, 197, 246, 255);
# var unsaved:Color = Color8(128, 211, 237, 255);
var unsaved:Color = Color8(129, 129, 129, 255);
var unsavedHighlight:Color = Color8(248, 220, 255, 255);

var focused:bool = false;

func focus_entered():
	Data.disableInput = true;
	focused = true;

func focus_exited():
	Data.disableInput = false;
	focused = false;

func entered(txt:String = ""):
	parseData(txt);
	emit_signal("entered", data);

func parseData(txt:String = ""):
	data = defaultData;
	data.str.normal = txt;
	data.str.trimmed = data.str.normal.strip_edges();
	data.float = float(data.str.trimmed);
	data.int.normal = int(floor(data.float));
	data.int.rounded = int(round(data.float));
	
	var parsed:JSONParseResult = JSON.parse(data.str.trimmed);
	if (parsed.error == OK):
		match (typeof(parsed.result)):
			TYPE_DICTIONARY:
				data.json.dictionary = parsed.result;
			TYPE_ARRAY:
				data.json.array = parsed.result;

func unfocus():
	input.release_focus();

func text_entered(txt:String = ""):
	entered(txt);
	unfocus();

func clicked(index, pos):
	if (index == 1 && !Utils.collide(pos, Vector2.ZERO, position + Vector2(rightSpacing / 2, 0), Vector2(rightSpacing, 40))):
		unfocus();

func _ready():
	defaultData = data;
	input.connect("focus_entered", self, "focus_entered");
	input.connect("focus_exited", self, "focus_exited");
	input.connect("text_changed", self, "text_changed");
	input.connect("text_entered", self, "text_entered");
	InputHandler.connect("globalMouseUp", self, "clicked");
	_fixData();
	pass;

func updateHighlighter():
	if (!saved):
		saved = Color.white;
	if (!unsaved):
		unsaved = Color8(129, 129, 129, 255);
	if (!focused):
		input.add_color_override("font_color", saved);
		highlighter.self_modulate = saved;
		return;
	input.add_color_override("font_color", unsaved);
	highlighter.self_modulate = unsavedHighlight;

func _fixData():
	label.rect_position.x = -leftSpacing;
	label.rect_size.x = leftSpacing;
	input.rect_position.x = 0;
	input.rect_size.x = rightSpacing;
	highlighter.rect_position.x = 0;
	highlighter.rect_size.x = rightSpacing;
	label.text = key + ":";
	input.placeholder_text = placeholder;
	input.text = defaultValue;
	updateHighlighter();

func _process(delta):
	updateHighlighter();
	pass;

func _draw():
	if (Engine.editor_hint):
		if (!label):
			label = get_node("Key");
		if (!input):
			input = get_node("TextField");
		if (!highlighter):
			highlighter = get_node("Highlighter");
		_fixData();

func setKey(val):
	key = val;
	refresh();

func setPH(val):
	placeholder = val;
	refresh();
	
func setDV(val):
	defaultValue = val;
	refresh();

func setLeftSpacing(val):
	leftSpacing = val;
	refresh();

func setRightSpacing(val):
	rightSpacing = val;
	refresh();

func setHS(val):
	highlightSpeed = val;
	refresh();

func refresh():
	hide();
	show();
