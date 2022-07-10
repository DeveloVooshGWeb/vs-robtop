extends Node2D

onready var list:Node2D = get_node("List");
onready var listContent:Node2D = list.get_node("ListContent");

onready var hud:Node2D = get_node("HUD");
onready var icon:AnimatedSprite = hud.get_node("Icon");
onready var percent:Label = hud.get_node("Percent");

var fnt:BitmapFont = load("res://assets/fonts/alphabet.tres");

var selected:int = 0;

var unselAlpha:float = 0.6;
var selAlpha:float = 1.0;

var itemHeight:int = 87;
var itemCount:int = 0;

var keyArr:Array = ["Up", "Down"];

func _jp(keyName:String):
	var key:int = keyArr.find(keyName);
	if (key >= 0):
		key -= 1;
		if (key == 0):
			key = 1;
		key = sign(key);
		Sound.play("scrollMenu");
		selected += key;
	pass;

func _ready():
	var i:int = 0;
	for song in Data.selectionData.songs:
		var label:Label = Label.new();
		label.align = Label.ALIGN_LEFT;
		label.valign = Label.VALIGN_CENTER;
		label.rect_size.x = 1280;
		label.rect_size.y = itemHeight;
		label.rect_position.y = i * itemHeight;
		label.theme = Theme.new();
		label.theme.default_font = fnt;
		label.modulate.a = unselAlpha;
		label.text = song.to_upper();
		listContent.add_child(label);
		i += 1;
	itemCount += i;
	InputHandler.connect("justPressed", self, "_jp");
	pass;

func _physics_process(delta):
	
	pass;

func _process(delta):
	if (!(selected in range(itemCount))):
		if (selected < 1):
			selected = 1;
		selected -= itemCount;
		selected = abs(selected);
	list.position.y = lerp(list.position.y, -(selected * itemHeight), 0.15);
	var i:int = 0;
	for label in listContent.get_children():
		if (i != selected):
			label.modulate.a = lerp(label.modulate.a, unselAlpha, 0.25);
		else:
			label.modulate.a = lerp(label.modulate.a, selAlpha, 0.25);
		i += 1;
	pass;
