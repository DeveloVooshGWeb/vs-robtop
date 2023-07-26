@tool
extends Node2D

signal entered(data);

@onready var label:Label = get_node("Key");
@onready var input:LineEdit = get_node("TextField");
@onready var highlighter:ColorRect = get_node("Highlighter");

@export var key:String = "Key": set = setKey;
@export var placeholder:String = "Placeholder": set = setPH;
@export var defaultValue:String = "": set = setDV;
@export var leftSpacing:float = 256.0: set = setLeftSpacing;
@export var rightSpacing:float = 256.0: set = setRightSpacing;
@export var highlightSpeed:float = 0.3: set = setHS;
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

var saved:Color = Color.WHITE;
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

func enteredF(txt:String = ""):
	parseData(txt);
	emit_signal("entered", data);

func parseData(txt:String = ""):
	data = defaultData;
	data.str.normal = txt;
	data.str.trimmed = data.str.normal.strip_edges();
	data.float = float(data.str.trimmed);
	data.int.normal = int(floor(data.float));
	data.int.rounded = int(round(data.float));
	
#	var test_json_conv = JSON.new()
#	test_json_conv.parse(data.str.trimmed);
#	var parsed:JSON = test_json_conv.get_data()
	var parsed = JSON.parse_string(data.str.trimmed);
	match (typeof(parsed)):
		TYPE_DICTIONARY:
			data.json.dictionary = parsed;
		TYPE_ARRAY:
			data.json.array = parsed;

func unfocus():
	input.release_focus();

func text_submitted(txt:String = ""):
	enteredF(txt);
	unfocus();

func clicked(index, pos):
	if (index == 1 && !Utils.collide(pos, Vector2.ZERO, position + Vector2(rightSpacing / 2, 0), Vector2(rightSpacing, 40))):
		unfocus();

func _ready():
	defaultData = data;
	input.connect("focus_entered", Callable(self, "focus_entered"));
	input.connect("focus_exited", Callable(self, "focus_exited"));
#	input.connect("text_changed", Callable(self, "text_changed"));
	input.connect("text_submitted", Callable(self, "text_submitted"));
	InputHandler.connect("globalMouseUp", Callable(self, "clicked"));
	_fixData();
	pass;

func updateHighlighter():
	if (saved != null):
		saved = Color.WHITE;
	if (unsaved != null):
		unsaved = Color8(129, 129, 129, 255);
	if (!focused):
		input.add_theme_color_override("font_color", saved);
		highlighter.self_modulate = saved;
		return;
	input.add_theme_color_override("font_color", unsaved);
	highlighter.self_modulate = unsavedHighlight;

func _fixData():
	label.position.x = -leftSpacing;
	label.size.x = leftSpacing;
	input.position.x = 0;
	input.size.x = rightSpacing;
	highlighter.position.x = 0;
	highlighter.size.x = rightSpacing;
	label.text = key + ":";
	input.placeholder_text = placeholder;
	input.text = defaultValue;
	updateHighlighter();

func _process(delta):
	updateHighlighter();
	pass;

func _draw():
	if (Engine.is_editor_hint()):
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
