extends Node2D

var initialized:Array = [false, false];
var songTitle:String = "";
var curChart:String = "";
var curSong:String = "";
var bpm:int = 130;
var difficulty:int = 1;
var speed:float = 0;

var noteRes:Resource = Assets.getScene("notes/Note");
var inputNotes:Array = [];
var noteList:Array = [];
var eventList:Array = [];
var instPos:float = 0;
var focuses:Array = [];
var holdList:Array = [[], [], [], []];
var keyMap:Array = ["Left", "Down", "Up", "Right"];

var rng:RandomNumberGenerator = RandomNumberGenerator.new();

onready var gameCam:Camera2D = get_node("GameCam");
onready var stage:Node2D;

onready var hudCam:Camera2D = get_node("HUDCam");
onready var strumContainer:Node2D = hudCam.get_node("Strums");
onready var strumY:float = strumContainer.get_node("StrumLine").position.y;
onready var strumPositions:Array = [
	strumContainer.get_node("S1").position.x,
	strumContainer.get_node("S2").position.x,
	strumContainer.get_node("S3").position.x,
	strumContainer.get_node("S4").position.x,
	strumContainer.get_node("S5").position.x,
	strumContainer.get_node("S6").position.x,
	strumContainer.get_node("S7").position.x,
	strumContainer.get_node("S8").position.x
];
onready var noteTree:Node2D = hudCam.get_node("Notes");
onready var healthBar:Node2D = hudCam.get_node("HealthBar");
onready var enemyBar:ColorRect = healthBar.get_node("EnemyBar");
onready var enemyIcon:AnimatedSprite = healthBar.get_node("EnemyIcon");
onready var playerIcon:AnimatedSprite = healthBar.get_node("PlayerIcon");

var health:float = 1;
var barSize:int = 888;
var iconData:Dictionary = {
	"offset": 64,
	"spacing": barSize / 2
};

var strums:Array = [];
var enemyStrums:Array = [];
var playerStrums:Array = [];
var inst:AudioStreamPlayer = null;
var voices:AudioStreamPlayer = null;

func initStrums():
	for i in range(strumPositions.size()):
		var strumPos:Vector2 = Vector2(strumPositions[i], strumY);
		var strum:Node2D = noteRes.instance();
		strum.properties.col = 0;
		strum.properties.row = 0;
		strum.properties.noteId = i % 4;
		strum.position = strumPos;
		strum.init();
		strum.resizeWH(Data.noteSize);
		strums.append(strum);
		strumContainer.add_child(strum);
	for i in range(strums.size()):
		var isPlayer:bool = i >= 4;
		if (!isPlayer):
			enemyStrums.append(strums[i]);
		else:
			playerStrums.append(strums[i]);
		
func setStage(path:String = "Rub"):
	stage = Assets.getStage(path).instance();
	stage.position = Vector2(-960, -540);
	gameCam.add_child(stage);

func instanceStage():
	match (curSong):
		_:
			setStage("Rub");

func noteSpawn(data:Dictionary):
	if (data.index is int):
		var note:Node2D = inputNotes[data.index];
		note.misc.spawned = true;
		noteTree.add_child(note);

func randn(arr:Array) -> int:
	var num:int = rng.randi();
	if (arr.has(num)):
		return randn(arr);
	return num;

func loadChart():
	var chartData:PoolByteArray = Assets.getBytes("data/charts/" + curChart + "/" + String(difficulty) + ".bin");
	var data:Dictionary = Chart.parse(chartData);
	bpm = int(data.bpm);
	BeatHandler.setBPM(bpm);
	curSong = String(data.song);
	speed = Data.speedMultiplier * float(data.speed);
	var i:int = 0;
	var j:int = 0;
	for section in data.sections:
		focuses.append(section.mustHitSection);
		var notes:Array = section.notes.duplicate(true);
		notes.sort_custom(Chart, "noteRowSort");
		for props in notes:
			var noteTime:float = (float(i * 16) + (float(props.row) / Data.rowCap)) * BeatHandler.stepSecs;
			if (props.col in range(8)):
				noteList.append({
					"props": props,
					"targetPos": Vector2(strumPositions[props.col], strumY),
					"time": noteTime,
					"speed": float(speed)
				});
			else:
				eventList.append({
					"time": noteTime,
					"events": GEVT.parse(props.evt)
				})
			j += 1;
		i += 1;

func loadSong():
	BeatHandler.connect("stepHit", self, "stepHit");
	BeatHandler.connect("beatHit", self, "beatHit");
	inst = Sound.loadMusic(curSong + "/Inst", 0, false);
	voices = Sound.loadMusic(curSong + "/Voices", 0, false);
	inst.play();
	if (voices):
		voices.play();
	BeatHandler.init(inst, bpm);

func missed(props:Dictionary, misc:Dictionary, isEnemy:bool):
	if (!isEnemy):
		health -= 0.075;
	pass;

func hit(props:Dictionary, misc:Dictionary, isEnemy:bool):
	if (!isEnemy):
		health += 0.05;
	pass;

func hold(props:Dictionary, misc:Dictionary, isEnemy:bool):
	if (!isEnemy):
		health += 0.0075;
	pass;

func justPressed(keyName:String):
	var key:int = keyMap.find(keyName);
	if (key in range(playerStrums.size())):
		var strum:Node2D = playerStrums[key];
		strum.press();
		for note in inputNotes:
			if (weakref(note).get_ref()):
				if (note.properties.noteId == key):
					var notePos:float = note.position.y - note.misc.targetPos.y;
					if (notePos - (note.size * note.scale).y <= 0 && notePos >= -(strum.size * strum.scale).y):
						strum.confirm();
						stage.confirm(key);
						inputNotes.remove(inputNotes.find(note));
						if (note.properties.noteLength <= 0.0):
							hit(note.properties.duplicate(true), note.misc.duplicate(true), note.properties.col < 4);
							noteTree.remove_child(note);
							note.call_deferred("free");
						else:
							if (weakref(note.note).get_ref()):
								note.note.call_deferred("free");
							holdList[key].append(note);

func pressed(keyName:String):
	var key:int = keyMap.find(keyName);
	if (key in range(playerStrums.size())):
		var strum:Node2D = playerStrums[key];
		var holds:Array = holdList[key];
		if (holds.size() > 0):
			strum.confirmLoop();
			stage.confirmLoop(key);
			for hold in holds:
				if (weakref(hold).get_ref()):
					hold(hold.properties.duplicate(true), hold.misc.duplicate(true), hold.properties.col < 4);
					hold.holdUpdate();
				else:
					holds.remove(holds.find(hold));

func justReleased(keyName:String):
	if (keyName == "7"):
		inst.playing = false;
		voices.playing = false;
		SceneTransition.switchAbsolute("res://charter/ChartingState");
	var key:int = keyMap.find(keyName);
	if (key in range(playerStrums.size())):
		holdList[key].empty();
		var strum:Node2D = playerStrums[key];
		strum.normal();
		stage.normal();

func loadIcons():
	if (Data.icons.has(curSong)):
		if (Data.icons[curSong] is Array):
			if (Data.icons[curSong].size() == 2):
				var curIcons:Array = Data.icons[curSong];
				enemyIcon.character = curIcons[0];
				playerIcon.character = curIcons[1];

func updateHealthBar():
	if (health < 0):
		health = 0;
	if (health > 2):
		health = 2;
	enemyBar.rect_size.x = iconData.spacing * (2.0 - health);
	var iconSpacing:float = (-iconData.spacing * health) + iconData.spacing;
	enemyIcon.position.x = iconSpacing - iconData.offset;
	playerIcon.position.x = iconSpacing + iconData.offset;

func init():
	initStrums();
	if (Data.loadData.queue.size() <= 0):
		Data.loadData.queue = ["Destruction"];
	songTitle = "" + Data.loadData.queue[0];
	Data.loadData.queue.pop_front();
	curChart = Utils.snake_case(songTitle);
	difficulty = Data.loadData.difficulty;
	rng.randomize();
	
	loadIcons();
	loadChart();
	instanceStage();
	loadSong();
	
	Data.song = "" + curSong;
	
	initialized[0] = true;
	InputHandler.connect("justPressed", self, "justPressed");
	InputHandler.connect("pressed", self, "pressed");
	InputHandler.connect("justReleased", self, "justReleased");
	SceneTransition.connect("finished", self, "_sceneLoaded");
	SceneTransition.init();

func _sceneLoaded():
	initialized[1] = true;

func _ready():
#	var thread:Thread = Thread.new();
#	thread.start(self, "init");
	init();
	pass;

func printIt(message:String):
	print(message);

func executeEvent(events:Array):
	for event in events:
		var ref:FuncRef = funcref(self, event.function);
		if (ref.is_valid()):
			ref.call_funcv(event.args);

func updateEvents():
	if (eventList.size() > 0):
		var eventData:Dictionary = eventList[0];
		var diff:float = eventData.time - instPos;
		if (diff <= 0.0):
			executeEvent(eventData.events);
			eventList.pop_front();

func updateNotes():
	if (noteList.size() > 0):
		var noteData:Dictionary = noteList[0];
		var diff:float = (noteData.time - instPos) - ((16.0 / speed) * BeatHandler.stepSecs);
		if (diff <= 0.0):
			var note:Node2D = noteRes.instance();
			note.properties = noteData.props;
			note.misc.speed = noteData.speed;
			note.misc.time = noteData.time;
			note.misc.targetPos = noteData.targetPos;
			note.position.x = note.misc.targetPos.x;
			note.position.y = 1920;
			note.init();
			note.resizeWH(Data.noteSize);
			noteTree.add_child(note);
			noteList.pop_front();

	for note in noteTree.get_children():
		instPos = BeatHandler.getPosition();
		note.position.y = float(note.misc.targetPos.y - (instPos * 1000.0 - note.misc.time * 1000.0) * speed);
		var sizeAdd:int = note.endSize.y;
		if (!note.holdEnd.texture):
			sizeAdd = note.size.y;
		var isEnemy:bool = note.properties.col < 4;
		if (!isEnemy && !inputNotes.has(note)):
			inputNotes.append(note);
		if (note.position.y + note.holdEnd.offset.y + float(sizeAdd / 2) <= 0.0):
			missed(note.properties.duplicate(true), note.misc.duplicate(true), isEnemy);
			note.call_deferred("free");

func _process(delta):
	if (!initialized.has(false)):
		if (inst):
			if (!BeatHandler.songFinished):
				instPos = inst.get_playback_position();
				if (voices):
					var vocalPos:float = voices.get_playback_position();
					if (abs(instPos - vocalPos) >= Data.vocalResetThreshold):
						voices.seek(instPos);
				updateEvents();
				updateNotes();
				updateHealthBar();
			else:
				voices = null;
				inst = null;
	pass;

func _fixed_process(delta):
	queue_free();
	pass;

func openURL(uri:String):
	OS.shell_open(uri);

func stepHit(steps:int):
	for strum in playerStrums:
		if (strum.loopConfirm && strum.note.animation.ends_with(strum.strumModifiers[1]) && strum.note.frame >= 3):
			strum.note.frame = 0;
	if (stage):
		stage.stepHit(steps);
	pass;

func beatHit(beats:int):
	if (stage):
		stage.beatHit(beats);
	pass;
