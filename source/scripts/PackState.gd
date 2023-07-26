extends Node2D

@onready var tableBG:Sprite2D = get_node("TableBG");
@onready var table:Node2D = get_node("Table");
@onready var tableContent:Node2D = table.get_node("TableContent");
@onready var frameHeight:int = 334;

var packItem:Resource = Assets.getScene("misc/PackItem");
var scrolling:bool = false;
var startPos:float = 0;
var maxScroll:float = 128;
var resetVel:float = 10;
var reset:bool = false;

var packs:Array[Dictionary] = [];
var tweeners:Array[CustomFloatTweener] = [];
var selected:int = -1;

func _tap(ind:int, pos:Vector2):
	if (ind == 1):
		reset = false;
		scrolling = Utils.collide(pos, Vector2.ZERO, tableBG.position, tableBG.texture.get_size() * tableBG.scale);
		startPos = pos.y;
		for i in range(packs.size()):
			var pack:Dictionary = packs[i];
			if (Utils.collide(pos, Vector2.ZERO, table.position + tableContent.position + pack.packNode.position + pack.view.position, pack.view.texture.get_size() * pack.view.scale)):
				selected = i;

func scrollTable(amount:int = 0, drag:bool = false):
	if (selected < 0):
		table.position.y += amount;
		var childCount:int = tableContent.get_child_count();
		var maxHeight:int = 0;
		if (childCount > 0):
			maxHeight = -(frameHeight - tableContent.get_child(childCount - 1).position.y);
			if (maxHeight < 0):
				maxHeight = 0;
		if (drag):
			maxHeight += maxScroll;
		if (table.position.y < -maxHeight):
			table.position.y = -maxHeight;
		if (!drag):
			if (table.position.y > 0):
				table.position.y = 0;
		else:
			if (table.position.y > maxScroll):
				table.position.y = maxScroll;
	pass;

func _drag(ind:int, pos:Vector2):
	if (ind == 1 && scrolling):
		if (selected < 0):
			var posDiff:float = pos.y - startPos;
			scrollTable(posDiff, true);
			startPos = pos.y;
		for i in range(packs.size()):
			var pack:Dictionary = packs[i];
			if (selected >= 0):
				if (Utils.collide(pos, Vector2(0, 0), table.position + tableContent.position + pack.packNode.position + pack.view.position, pack.view.texture.get_size() * pack.view.scale)):
					selected = i;
					var tweener:CustomFloatTweener = tweeners[selected];
					if (tweener.inverted):
						tweener.play();
				else:
					if (i == selected):
						selected = -1;
					var tweener:CustomFloatTweener = tweeners[i];
					if (!tweener.inverted):
						tweener.play_invert();

func _scroll(ind:int, pos:Vector2):
	var scrollInd:int = ind - 1;
	if (scrollInd >= 0):
		scrollInd = 1;
	if (Utils.collide(pos, Vector2.ZERO, tableBG.position, tableBG.texture.get_size() * tableBG.scale)):
		scrollTable(-15 * scrollInd);

func _release(ind:int, pos:Vector2):
	if (ind == 1):
		for i in range(packs.size()):
			var tweener:CustomFloatTweener = tweeners[i];
			if (!tweener.inverted):
				tweener.play_invert();
		reset = true;
		if (selected >= 0):
			SceneTransition.switch("SelectionState");
			selected = -1;

func packInit():
	for i in range(Data.packData.size()):
		var pack:Dictionary = Data.packData[i];
		var tableType:int = i % 2;
		var packNode:Node2D = packItem.instantiate();
		packNode.col = pack.color;
		packNode.packName = pack.pack;
		packNode.songs = pack.songs;
		packNode.tableType = tableType;
		packNode.difficulty = pack.diff;
		packNode.position.y = i * 256;
		tableContent.add_child(packNode);
		var viewBtn:Sprite2D = packNode.get_node("ViewBtn");
		var anim:String = "View" + str(i);
		var tweener:CustomFloatTweener = CustomFloatTweener.new(1.5, 2.0, 0.35, Tween.TRANS_BOUNCE, Tween.EASE_OUT);
		tweener.inverted = true;
		add_child(tweener);
		tweeners.append(tweener);
		packs.append({
			"pack": pack,
			"packNode": packNode,
			"view": viewBtn
#			"anim": anim
		});
		
func _ready():
#	yield(VisualServer, "frame_post_draw");
#	var img = $ViewportContainer/Viewport.get_texture().get_data();
#	img.flip_y();
#	img.save_png("fg.png");
	packInit();
	InputHandler.connect("mouseDown", Callable(self, "_tap"));
	InputHandler.connect("mouseDrag", Callable(self, "_drag"));
	InputHandler.connect("mouseScroll", Callable(self, "_scroll"));
	InputHandler.connect("mouseUp", Callable(self, "_release"));
	pass;

func _physics_process(delta):
	if (reset):
		if (table.position.y > 0):
			table.position.y -= resetVel;
			if (table.position.y < 0):
				table.position.y = 0;
		var childCount:int = tableContent.get_child_count();
		var maxHeight:int = 0;
		if (childCount > 0):
			maxHeight = -(frameHeight - tableContent.get_child(childCount - 1).position.y);
			if (maxHeight < 0):
				maxHeight = 0;
		if (table.position.y < -maxHeight):
			table.position.y += resetVel;
			if (table.position.y > -maxHeight):
				table.position.y = -maxHeight;
	pass;

func _process(delta):
	for i in range(packs.size()):
		var pack:Dictionary = packs[i];
		var daScale:float = tweeners[i].current();
		pack.view.scale = Vector2(daScale, daScale);
	pass;
