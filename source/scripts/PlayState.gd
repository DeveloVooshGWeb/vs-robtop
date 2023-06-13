extends Node2D

var initialized:Array = [false, false];
var songTitle:String = "";
var curChart:String = "";
var curSong:String = "";
var bpm:int = 130;
var difficulty:int = 1;
var speed:float = 0;

var notesHit:float = 0;
var notesPassed:float = 0;
var score:int = 0;
var misses:int = 0;
var health:float = 1;
var accuracy:float = 0;
var coins:int = 0;

var finished:bool = false;

var sigobashList:Node2D;
var noteRes:Resource = Assets.getScene("notes/Note");
var sigobashRes:Resource = Assets.getScene("misc/SiGoBaSh");
var inputNotes:Array = [];
var noteList:Array = [];
var eventList:Array = [];
var instPos:float = 0;
var focuses:Array = [];
var holdList:Array = [[], [], [], []];
var enemyHoldList:Array = [[], [], [], []];
var enemyPressTimers:Array = [Timer.new(), Timer.new(), Timer.new(), Timer.new()];
var enemyPressTime:float = 0.15;
var noteAcceptThres:float = 0.1;
var rsgCount:int = 0;
var rsgMap:Array = ["nothing", "ready", "set", "go"];
var rsgAudioMap:Array = ["intro3", "intro2", "intro1", "introGo"];
var keyMap:Dictionary = {
	"Left": 0,
	"Down": 1,
	"Up": 2,
	"Right": 3,
	
	"D": 0,
	"F": 1,
	"J": 2,
	"K": 3
};

var rng:RandomNumberGenerator = RandomNumberGenerator.new();

@onready var stageViewport:SubViewport = get_node("StageViewport/SubViewport");
@onready var stage:Node2D;

@onready var hudViewport:SubViewport = get_node("HUDViewport/SubViewport");
@onready var hud:Node2D = hudViewport.get_node("HUD");
@onready var hudCam:Camera2D = hud.get_node("HUDCam");
@onready var strumContainer:Node2D = hud.get_node("Strums");
@onready var strumY:float = strumContainer.get_node("StrumLine").position.y;
@onready var strumPositions:Array = [
	strumContainer.get_node("S1").position.x,
	strumContainer.get_node("S2").position.x,
	strumContainer.get_node("S3").position.x,
	strumContainer.get_node("S4").position.x,
	strumContainer.get_node("S5").position.x,
	strumContainer.get_node("S6").position.x,
	strumContainer.get_node("S7").position.x,
	strumContainer.get_node("S8").position.x
];
@onready var noteTree:Node2D = hud.get_node("Notes");
@onready var healthBar:Node2D = hud.get_node("HealthBar");
@onready var enemyBar:ColorRect = healthBar.get_node("EnemyBar");
@onready var enemyIcon:AnimatedSprite2D = healthBar.get_node("EnemyIcon");
@onready var playerIcon:AnimatedSprite2D = healthBar.get_node("PlayerIcon");

@onready var rsgTimer:Timer = get_node("RSGTimer");
@onready var rsgTween:Tween = get_tree().create_tween().set_parallel(true);
@onready var rsg:AnimatedSprite2D = hud.get_node("RSG");

@onready var stats:Node2D = get_node("Stats");

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
var startedCountdown:bool = false;

var finishedStats:bool = false;

func initStrums():
	for i in range(strumPositions.size()):
		var strumPos:Vector2 = Vector2(strumPositions[i], strumY);
		var strum:Node2D = noteRes.instantiate();
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
	stage = Assets.getStage(path).instantiate();
	stage.position = Vector2(-960, -540);
	stageViewport.add_child(stage);
	sigobashList = stage.get_node("SiGoBaShList");

func instanceStage():
	match (curSong):
		_:
			setStage("Rub");

func randn(arr:Array) -> int:
	var num:int = rng.randi();
	if (arr.has(num)):
		return randn(arr);
	return num;

func loadChart():
	var chartData:PackedByteArray = Assets.getBytes("data/charts/" + curChart + "/" + str(difficulty) + ".bin");
	var data:Dictionary = Chart.parse(chartData);
	bpm = int(data.bpm);
	BeatHandler.setBPM(bpm);
	curSong = str(data.song);
	speed = Data.speedMultiplier * float(data.speed);
	var i:int = 0;
	var j:int = 0;
	for section in data.sections:
		focuses.append(section.mustHitSection);
		var notes:Array = section.notes.duplicate(true);
		notes.sort_custom(Callable(Chart, "noteRowSort"));
		for props in notes:
			var noteSteps:float = float(i * 16) + (float(props.row) / Data.rowCap);
			var noteTime:float = noteSteps * BeatHandler.stepSecs;
			if (props.col in range(8)):
				noteList.append({
					"props": props,
					"targetPos": Vector2(strumPositions[props.col], strumY),
					"steps": noteSteps,
					"time": noteTime,
					"speed": float(speed)
				});
			else:
				eventList.append({
					"steps": noteSteps,
					"time": noteTime,
					"events": GEVT.parse(props.evt)
				})
			j += 1;
		i += 1;

func endSong():
	Sound.stopAll();
	finished = true;
#	if (!SaveManager.songs[curSong]):
#		SaveManager.songs[curSong] = [0, 0, 0];
#	SaveManager.songs[curSong][difficulty] = score;
#	SaveManager.save();
	stats.init(score, misses, accuracy, coins);
	stats.visible = true;
	pass;

func statsFinished():
	finishedStats = true;
	pass;

func loadSong():
	BeatHandler.connect("stepHit", Callable(self, "stepHit"));
	BeatHandler.connect("beatHit", Callable(self, "beatHit"));
	BeatHandler.connect("sectionHit", Callable(self, "sectionHit"));
	BeatHandler.connect("finished", Callable(self, "endSong"));
	
	inst = Sound.loadMusic(curSong + "/Inst", 0, false);
	voices = Sound.loadMusic(curSong + "/Voices", 0, false);
	BeatHandler.init(inst, bpm);
	BeatHandler.songPos = 0 - (BeatHandler.beatSecs * 5);
	BeatHandler.startPlaying();
	startedCountdown = true;
	rsgTimer.start(BeatHandler.beatSecs);

func missed(props:Dictionary, misc:Dictionary, isEnemy:bool, ignoreMissCount:bool = false):
	if (!isEnemy):
		if (Data.noteTypeLabels.has(props.noteType)):
			var noteType:String = Data.noteTypeLabels[props.noteType];
			match (noteType):
				"Note", "Good":
					if (voices):
						voices.volume_db = -72;
					health -= 0.075;
					updateScore(0, true);
					stage.bfMiss(props.col % 4);
					Sound.play("missnote" + str(rng.randi_range(1, 3)), -12);
					notesPassed += 0.25;
					if (!ignoreMissCount):
						misses += 1;
						hud.updMisses(misses);
				"Bad":
					if (voices):
						voices.volume_db = 0;
					updateScore(0, false, true);
			hud.updHealth(health);
	pass;

func hit(props:Dictionary, misc:Dictionary, isEnemy:bool):
	if (voices):
		voices.volume_db = 0;
	if (!isEnemy):
		if (Data.noteTypeLabels.has(props.noteType)):
			var noteType:String = Data.noteTypeLabels[props.noteType];
			match (noteType):
				"Note":
					health += 0.05;
				"Bad":
					if (voices):
						voices.volume_db = -72;
					health -= 0.075;
					updateScore(0.0, true);
					stage.bfMiss(props.col % 4);
					Sound.play("missnote" + str(rng.randi_range(1, 3)), -12);
					notesPassed += 0.25;
					misses += 1;
					hud.updMisses(misses);
				"Coin":
					coins += 1;
			hud.updHealth(health);
	pass;

func hold(props:Dictionary, misc:Dictionary, isEnemy:bool):
	if (voices):
		voices.volume_db = 0;
	if (!isEnemy):
		health += 0.0075;
		hud.updHealth(health);
	pass;

func updateSiGoBaSh():
	if (sigobashList):
		for sigobash in sigobashList.get_children():
			if (!weakref(sigobash).get_ref()):
				sigobashList.remove_child(sigobash);
	pass;

func updateScore(noteTime:float, forceShit:bool = false, forceSick:bool = false):
	var noteDiff:float = abs(noteTime - BeatHandler.getPosition());
	var sigobash:Node2D = sigobashRes.instantiate();
	notesPassed += 1;
	if ((noteDiff > Data.sigobashOffsets[0] || forceShit) && !forceSick):
		if (!forceShit):
			score += 50;
			notesHit += 0.25;
		sigobash.curFrame = 3;
	elif (noteDiff > Data.sigobashOffsets[1] && !forceSick):
		score += 100;
		notesHit += 0.25;
		sigobash.curFrame = 2;
	elif (noteDiff > Data.sigobashOffsets[2] && !forceSick):
		score += 200;
		notesHit += 0.95;
		sigobash.curFrame = 1;
	elif (noteDiff > Data.sigobashOffsets[3] || forceSick):
		score += 350;
		notesHit += 1;
		notesPassed -= 0.001;
		sigobash.curFrame = 0;
	hud.updScore(score);

	var acc:float = 1;
	if (notesPassed < 0):
		notesPassed = 0;
	if (notesHit > notesPassed):
		notesHit = notesPassed;
	if (notesPassed != 0):
		acc = notesHit / notesPassed;
	if (acc < 0):
		acc = 0;
	if (acc > 1):
		acc = 1;
	accuracy = snapped(acc * 100.0, 0.01);
	hud.updAccuracy(accuracy);

	if (sigobashList):
		sigobashList.add_child(sigobash);
	pass;

func justPressed(keyName:String):
	var key:int = -1;
	if (keyMap.has(keyName)):
		key = keyMap[keyName];
	if (key in range(playerStrums.size())):
		var strum:Node2D = playerStrums[key];
		strum.press();
		for note in inputNotes:
			if (weakref(note).get_ref()):
				var isEnemy:bool = note.properties.col < 4;
				var notePos:float = note.position.y - note.misc.targetPos.y;
				if (notePos - Data.noteSize <= 0 && notePos >= -Data.noteSize):
					if (note.properties.noteId == key):
						strum.confirm();
						stage.bfConfirm(key, note.properties.alt);
						updateScore(note.misc.time);
						inputNotes.erase(note);
						if (note.properties.noteLength <= 0.0):
							hit(note.properties, note.misc, isEnemy);
							noteTree.remove_child(note);
							note.queue_free();
							note.call_deferred("free");
						else:
							if (weakref(note.note).get_ref()):
								note.note.queue_free();
								note.note.call_deferred("free");
							holdList[key].append(note);
					else:
						if (weakref(note.note).get_ref()):
							var exemption:bool = false;
							var usedNote:Node2D = null;
							for curNote in inputNotes:
								if (weakref(curNote).get_ref()):
									var stepDiff:float = note.misc.steps - curNote.misc.steps;
									if (curNote.properties.noteId == key):
										if (stepDiff >= 0 && stepDiff <= noteAcceptThres):
											exemption = true;
										break;
							if (!exemption):
								missed(note.properties, note.misc, isEnemy);
	if (finishedStats && keyName == "Enter"):
		SceneTransition.switch("MainMenuState");

func pressed(keyName:String):
	var key:int = -1;
	if (keyMap.has(keyName)):
		key = keyMap[keyName];
	if (key in range(playerStrums.size())):
		var strum:Node2D = playerStrums[key];
		var holds:Array = holdList[key];
		if (holds.size() > 0):
			for hold in holds:
				if (weakref(hold).get_ref()):
					strum.confirmLoop();
					stage.bfConfirmLoop(key, hold.properties.alt);
					hold(hold.properties.duplicate(true), hold.misc.duplicate(true), hold.properties.col < 4);
					hold.holdUpdate();
				else:
					holds.erase(hold);

func justReleased(keyName:String):
	if (keyName == "7"):
		inst.playing = false;
		voices.playing = false;
		SceneTransition.switchAbsolute("res://charter/ChartingState");
	var key:int = -1;
	if (keyMap.has(keyName)):
		key = keyMap[keyName];
	if (key in range(playerStrums.size())):
		holdList[key].is_empty();
		var strum:Node2D = playerStrums[key];
		strum.normal();
		stage.bfNormal();

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
		hud.updHealth(health);
	if (health > 2):
		health = 2;
		hud.updHealth(health);
	enemyBar.size.x = iconData.spacing * (2.0 - health);
	var iconSpacing:float = (-iconData.spacing * health) + iconData.spacing;
	enemyIcon.position.x = iconSpacing - iconData.offset;
	playerIcon.position.x = iconSpacing + iconData.offset;

func rsgUpdate():
	if (rsgCount < 5):
		BeatHandler.songPos = 0 - (BeatHandler.beatSecs * (4 - rsgCount));
		if (rsgCount < 4):
			rsg.play(rsgMap[rsgCount]);
			if (rsgCount > 0):
				rsg.position = Data.vec2cen;
				rsg.modulate.a = 1.0;
				if (rsgTween):
					rsgTween.kill();
				rsgTween = get_tree().create_tween().set_parallel(true);
# TOOD: LEARN TWEENING MADAFAKA
				rsg.position = Data.vec2cen;
				rsgTween.tween_property(rsg, "position", Data.vec2cen + Vector2(0, 25), BeatHandler.beatSecs).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT);
				rsg.modulate = Color.WHITE;
				rsgTween.tween_property(rsg, "modulate:a", 0, BeatHandler.beatSecs).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT);
			#   rsgTween.start();
			Sound.play(rsgAudioMap[rsgCount], -12);
		stage.beatHit(-1, true);
		rsgCount += 1;
		if (rsgCount >= 5):
			startedCountdown = false;
			inst.play();
			if (voices):
				voices.play();
			rsgTimer.stop();
	pass;

func cache():
#	for i in range(Data.noteVariants.size()):
#		Assets.getSpriteFrames("notes/type" + str(i));
#	for i in range(4):
#	var sprFrames:SpriteFrames = Assets.getSpriteFrames("notes/type8");
#	var animNames:Array = sprFrames.get_animation_names();
#	for anim in animNames:
#		for j in range(sprFrames.get_frame_count(anim)):
#			sprFrames.get_frame(anim, j).get_data().save_png("res://assets/png/notes/type8/" + Utils.snake_case(anim).to_upper() + "_" + String(j) + ".png");
	for i in range(Data.noteVariants.size()):
		for j in range(4):
			Assets.getSpriteFrames("notes/" + str(i) + "_N" + str(j));
	Assets.getSpriteFrames("play/sigobash");
	for i in range(3):
		Assets.getAudio("missnote" + str(i + 1));
	pass;

func initPressTimers():
	for i in range(4):
		enemyPressTimers[i].one_shot = true;
		enemyPressTimers[i].connect("timeout", Callable(self, "enmRelease").bind(i));
		add_child(enemyPressTimers[i]);
	pass;

func init():
	stageViewport.canvas_item_default_texture_filter = SubViewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_LINEAR_WITH_MIPMAPS;
	hudViewport.canvas_item_default_texture_filter = SubViewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_LINEAR_WITH_MIPMAPS;
	
	initStrums();
	if (Data.loadData.queue.size() <= 0):
		Data.loadData.queue = ["Destruction"];
	songTitle = "" + Data.loadData.queue[0];
	Data.loadData.queue.pop_front();
	curChart = Utils.snake_case(songTitle);
	difficulty = Data.loadData.difficulty;
	
	rng.randomize();
	
	cache();
	initPressTimers();
	loadIcons();
	loadChart();
	instanceStage();
	loadSong();
	
	Data.song = "" + curSong;
	
	rsgTimer.connect("timeout", Callable(self, "rsgUpdate"));
	InputHandler.connect("justPressed", Callable(self, "justPressed"));
	InputHandler.connect("pressed", Callable(self, "pressed"));
	InputHandler.connect("justReleased", Callable(self, "justReleased"));
	SceneTransition.connect("finished", Callable(self, "_sceneLoaded"));
	stats.connect("finishedStats", Callable(self, "statsFinished"));
	
	initialized[0] = true;
	
	SceneTransition.init();

func _sceneLoaded():
	initialized[1] = true;

func _ready():
#	var thread:Thread = Thread.new();
#	thread.start(self, "init");
	init();
	pass;

func executeEvent(events:Array):
	for event in events:
		var ref:Callable = Callable(self, event.function);
		if (ref.is_valid()):
			ref.callv(event.args);

func updateEvents():
	if (eventList.size() > 0):
		var eventData:Dictionary = eventList[0];
		var diff:float = eventData.time - instPos;
		if (diff <= 0.0):
			executeEvent(eventData.events);
			eventList.pop_front();

func enmRelease(idx:int):
	enemyStrums[idx].normal();
	stage.enmNormal();
	pass;

func updateNotes():
	if (noteList.size() > 0):
		var noteData:Dictionary = noteList[0];
		var diff:float = (noteData.time - instPos) - ((16.0 / speed) * BeatHandler.stepSecs);
		if (diff <= 0.0):
			var note:Node2D = noteRes.instantiate();
			note.properties = noteData.props;
			note.misc.speed = noteData.speed;
			note.misc.steps = noteData.steps;
			note.misc.time = noteData.time;
			note.misc.targetPos = noteData.targetPos;
			note.position.x = note.misc.targetPos.x;
			note.position.y = 1920;
			note.init();
			note.resizeWH(Data.noteSize);
			noteTree.add_child(note);
			note.note.scale = Data.hardcodedNoteScales[note.properties.noteType];
			noteList.pop_front();

	var curSteps:float = BeatHandler.getSteps();
	instPos = BeatHandler.getPosition();
	for note in noteTree.get_children():
#		note.position.y = float(note.misc.targetPos.y - (instPos * 1000.0 - note.misc.time * 1000.0) * speed);
		note.position.y = float(note.misc.targetPos.y + ((note.misc.steps - curSteps) * (Data.noteSize * speed)));
		var sizeAdd:int = note.endSize.y;
		if (!note.holdEnd.texture):
			sizeAdd = note.size.y;
		var isEnemy:bool = note.properties.col < 4;
		var col:int = note.properties.col % 4;
		var ignoreMissCount:bool = false;
		if (!isEnemy && !inputNotes.has(note)):
			inputNotes.append(note);
		elif (isEnemy):
			if (note.misc.time <= instPos && col in range(enemyStrums.size())):
				var strum:Node2D = enemyStrums[col];
				var holds:Array = enemyHoldList[col];
				if (!holds.has(note)):
					strum.confirm();
					stage.enmConfirm(col, note.properties.alt);
					hit(note.properties, note.misc, isEnemy);
					if (note.properties.noteLength <= 0.0):
						noteTree.remove_child(note);
						note.queue_free();
						note.call_deferred("free");
						enemyPressTimers[col].stop();
						enemyPressTimers[col].start(enemyPressTime);
					else:
						if (weakref(note.note).get_ref()):
							ignoreMissCount = true;
							note.note.queue_free();
							note.note.call_deferred("free");
						holds.append(note);
				else:
					strum.confirmLoop();
					stage.enmConfirmLoop(col, note.properties.alt);
					hold(note.properties, note.misc, isEnemy);
					note.holdUpdate();
					var noteDead:bool = !weakref(note).get_ref();
					if (!noteDead):
						noteDead = note.dead;
					if (noteDead):
						strum.normal();
						stage.enmNormal();
						holds.erase(note);
		if (weakref(note).get_ref()):
			if (note.position.y + note.holdEnd.offset.y + float(sizeAdd / 2) <= 0.0):
				missed(note.properties, note.misc, isEnemy, ignoreMissCount);
				noteTree.remove_child(note);
				note.queue_free();
				note.call_deferred("free");

func _process(delta):
	if (!initialized.has(false)):
		if (!finished):
			if (!startedCountdown && inst):
				if (!BeatHandler.songFinished):
					instPos = BeatHandler.getPosition();
					if (voices):
						var instPlaybackPos:float = inst.get_playback_position();
						var vocalPos:float = voices.get_playback_position();
						if (abs(instPlaybackPos - vocalPos) >= Data.vocalResetThreshold):
							voices.seek(instPlaybackPos);
				else:
					voices = null;
					inst = null;
			for strum in strums:
				if (weakref(strum.note).get_ref()):
					if (strum.note.animation.count("Confirm") > 0):
						strum.note.offset = strum.origNOffset + (strum.strumOffsets[strum.properties.noteId] * strum.scale);
					else:
						strum.note.offset = strum.origNOffset;
			updateEvents();
			updateNotes();
			updateHealthBar();
			updateSiGoBaSh();
	pass;

func _fixed_process(delta):
#	queue_free();
	pass;

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

func sectionHit(sections:int):
	if (focuses.size() > 0 && stage):
		stage.focus(focuses[0]);
		focuses.pop_front();
	pass;

# CHARTER FUNCTIONS
func printIt(message:String):
	print(message);
func openURL(uri:String):
	OS.shell_open(uri);
