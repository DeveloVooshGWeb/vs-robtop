extends Node2D

onready var Easing = preload("res://Easing/Easing.gd");

var t = 0;

var buttonList:Array = [
	"PlayBtn",
	"BonusSongsBtn",
	"StatsBtn",
	"OptsBtn",
	"CreditsBtn",
];

var mouseSelected:String = "";

func init():
	EaseHandler.clear();
	for btn in buttonList:
		EaseHandler.setEase(btn, 0.6, 0.75, 0.3, "Bounce", "EaseOut");
	InputHandler.connect("mouseDown", self, "_onPressed");
	InputHandler.connect("mouseDrag", self, "_onDrag");
	InputHandler.connect("mouseUp", self, "_onReleased");
	Assets.getText();

func _ready():
	var thread:Thread = Thread.new();
	thread.start(self, "init");
	pass;

func _onPressed(index:int, pos:Vector2):
	if (index == 1):
		for btn in buttonList:
			var btnNode:Sprite = get_node(btn);
			if (Utils.collide(pos, Vector2(0, 0), btnNode.position, btnNode.texture.get_size() * btnNode.transform.get_scale())):
				mouseSelected = btn;

func _onDrag(index:int, pos:Vector2):
	if (index == 1):
		for btn in buttonList:
			if (mouseSelected != ""):
				var btnNode:Sprite = get_node(btn);
				if (Utils.collide(pos, Vector2(0, 0), btnNode.position, btnNode.texture.get_size() * btnNode.transform.get_scale())):
					mouseSelected = btn;
					EaseHandler.playEase(btn);
				else:
					EaseHandler.playEase(btn, true);

func _onReleased(index:int, pos:Vector2):
	if (index == 1):
		for btn in buttonList:
			EaseHandler.playEase(btn, true);
	if (buttonList.has(mouseSelected)):
		var selected:int = buttonList.find(mouseSelected);
		match (selected):
			0:
				print("Go To Story Menu");
			1:
				print("Show The Bonus Songs");
			2:
				print("Show The Player Stats");
			3:
				print("Go To The Options");
			4:
				print("Roll The Credits");
			_:
				print("Invalid Selection!");
	mouseSelected = "";

func _process(delta):
	for btn in buttonList:
		var btnNode:Sprite = get_node(btn);
		var daScale:float = EaseHandler.getEase(btn);
		btnNode.scale.x = daScale;
		btnNode.scale.y = daScale;
	pass;

func _fixed_process(delta):
	queue_free();
	pass;
