extends Node2D

@onready var cam:Camera2D = get_node("Cam");
@onready var camCanvas:CanvasLayer = cam.get_node("CanvasLayer");
@onready var shaderRect:ColorRect = camCanvas.get_node("ShaderRect");
@onready var shaderTween:Tween = create_tween().set_parallel(true);

var shaderOffset:float = 2;
var mouseSelected:String = "";
var buttonList:PackedStringArray = [
	"PlayBtn",
	"BonusSongsBtn",
	"StatsBtn",
	"OptsBtn",
	"CreditsBtn",
];
var tweenList:Array[CustomFloatTweener] = [];

func init():
	for btn in buttonList:
		var tweener:CustomFloatTweener = CustomFloatTweener.new(0.6, 0.75, 0.3, Tween.TRANS_BOUNCE, Tween.EASE_OUT);
		tweener.inverted = true;
		add_child(tweener);
		tweenList.append(tweener);
	InputHandler.connect("mouseDown", Callable(self, "_onPressed"));
	InputHandler.connect("mouseDrag", Callable(self, "_onDrag"));
	InputHandler.connect("mouseUp", Callable(self, "_onReleased"));
	BeatHandler.connect("beatHit", Callable(self, "beatHit"));
	if (!weakref(BeatHandler.song).get_ref()):
		BeatHandler.init(Sound.playMusic("rub", 0.5, true, true), 128);
	BeatHandler.startPlaying();

func beatHit(beats:int):
#	print(beats);
	if (shaderTween):
		shaderTween.kill();
	shaderTween = get_tree().create_tween().set_parallel(true);
	shaderTween.tween_property(shaderRect.material, "shader_parameter/offset", 0, 0.5).from(shaderOffset);
	CustomFloatTweener.new();
	pass;

func _ready():
#	var thread:Thread = Thread.new();
#	thread.start(Callable(self, "init"));
	init();
	pass;

func _onPressed(index:int, pos:Vector2):
	if (index == 1):
		for btn in buttonList:
			var btnNode:Sprite2D = get_node(btn);
			if (Utils.collide(pos, Vector2(0, 0), btnNode.position, btnNode.texture.get_size() * btnNode.transform.get_scale())):
				mouseSelected = btn;

func _onDrag(index:int, pos:Vector2):
	if (index == 1):
		for i in range(buttonList.size()):
			var btn:String = buttonList[i];
			if (mouseSelected != ""):
				var btnNode:Sprite2D = get_node(btn);
				var tweener:CustomFloatTweener = tweenList[i];
				if (Utils.collide(pos, Vector2(0, 0), btnNode.position, btnNode.texture.get_size() * btnNode.transform.get_scale())):
					mouseSelected = btn;
					if (tweener.inverted):
						tweener.play();
				else:
					if (!tweener.inverted):
						tweener.play_invert();

func _onReleased(index:int, pos:Vector2):
	if (index == 1):
		for i in range(buttonList.size()):
			var tweener:CustomFloatTweener = tweenList[i];
			if (!tweener.inverted):
				tweener.play_invert(0);
	if (buttonList.has(mouseSelected)):
		var selected:int = buttonList.find(mouseSelected);
		match (selected):
			0:
				print("Go To Story Menu");
				SceneTransition.switchWithText("PlayState", true);
			1:
				print("Show The Bonus Songs");
				SceneTransition.switch("PackState");
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
	for i in range(buttonList.size()):
		var btn:String = buttonList[i];
		var btnNode:Sprite2D = get_node(btn);
		
		var tweener:CustomFloatTweener = tweenList[i];
		var daScale:float = tweener.current();
		btnNode.scale = Vector2(daScale, daScale);
	pass;

#func _fixed_process(delta):
#	queue_free();
#	pass;
