@tool
extends Node2D

@export var col:Color = Color8(255, 255, 255, 255) : set = setCol;
@export var packName:String = "": set = setPackName;
@export var completed:int = 0: set = setCompleted;
@export var songs:int = 0: set = setSongs;
@export var tableType:int = 0: set = setTableType;
@export var difficulty:int = 0: set = setDiff;

@onready var table:AnimatedSprite2D = get_node("Table");
@onready var diffIcon:AnimatedSprite2D = get_node("DiffIcon");
@onready var title:Label = get_node("Title");
@onready var bar:Sprite2D = get_node("Bar");
@onready var progress:Label = get_node("Progress");
@onready var check:Sprite2D = get_node("Check");
@onready var viewBtn:Sprite2D = get_node("ViewBtn");

func setCol(val):
	col = val;
	refresh();

func setPackName(val):
	packName = val;
	refresh();

func setCompleted(val):
	completed = val;
	refresh();

func setSongs(val):
	songs = val;
	if (songs <= 0):
		songs = 1;
	refresh();

func setTableType(val):
	tableType = val;
	refresh();

func setDiff(val):
	difficulty = val;
	refresh();

func refresh():
	hide();
	show();

func update():
	title.modulate = col;
	bar.modulate = col;
	title.text = (packName + " Pack").strip_edges();
	progress.text = str(completed) + "/" + str(songs);
	bar.region_rect.size.x = int((float(completed) / songs) * 512);
	table.frame = tableType;
	diffIcon.frame = difficulty;
	check.visible = completed >= songs;
	pass;

func _ready():
	update();
	pass;

func _draw():
	if (Engine.is_editor_hint()):
		if (!table):
			table = get_node("Table");
		if (!diffIcon):
			diffIcon = get_node("DiffIcon");
		if (!title):
			title = get_node("Title");
		if (!bar):
			bar = get_node("Bar");
		if (!progress):
			progress = get_node("Progress");
		if (!check):
			check = get_node("Check");
		if (!viewBtn):
			viewBtn = get_node("ViewBtn");
		update();
