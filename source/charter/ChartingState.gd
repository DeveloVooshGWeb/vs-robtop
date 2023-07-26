extends Node2D

@onready var grid:Node2D = get_node("Grid");
@onready var glowRect:ColorRect = grid.get_node("GlowRect");
@onready var noteTree:Node2D = grid.get_node("Notes");

@onready var acpp:Node2D = get_node("AltChartPropsPanel");
@onready var sngi:Node2D = acpp.get_node("Song");
@onready var relb:Node2D = acpp.get_node("Reload");
@onready var lcb:Node2D = acpp.get_node("Load");
@onready var scb:Node2D = acpp.get_node("Save");
@onready var csb:Node2D = acpp.get_node("Copy");
@onready var psb:Node2D = acpp.get_node("Paste");
@onready var sncb:Node2D = acpp.get_node("SNC");
@onready var snrb:Node2D = acpp.get_node("SNR");

@onready var spp:Node2D = get_node("SectionPropsPanel");
@onready var fpb:Node2D = spp.get_node("Focus");

@onready var npp:Node2D = get_node("NotePropsPanel");
@onready var oxi:Node2D = npp.get_node("OffsetX");
@onready var oyi:Node2D = npp.get_node("OffsetY");
@onready var leni:Node2D = npp.get_node("Length");
@onready var aab:Node2D = npp.get_node("Alternative");

@onready var epp:Node2D = get_node("EventPropsPanel");
@onready var gevti:Node2D = epp.get_node("GEVTInput");

@onready var enl:Label = get_node("ExtraNote");
@onready var sdl:Label = get_node("SectionDisplay");

var sdlBase:String = "Current Section: ";

@onready var cpp:Node2D = get_node("ChartPropsPanel");
@onready var bpmi:Node2D = cpp.get_node("BPM");
@onready var spi:Node2D = cpp.get_node("Speed");
@onready var iob:Node2D = cpp.get_node("IO");
@onready var vob:Node2D = cpp.get_node("VO");

@onready var ntl:Label = get_node("NoteType");

@onready var ld:FileDialog = get_node("OpenDialog");
@onready var sd:FileDialog = get_node("SaveDialog");

var noteScene:Resource = preload("res://scenes/notes/Note.tscn");
var gridY:float = 768;
var defaultGridPos:Vector2 = Vector2(-460, -56);
var glowPos:Vector2 = defaultGridPos;
var disabledGlowPos:Vector2 = Vector2(-768, -56);
var snap:bool = true;
var altMode:bool = false;
var ctrlMode:bool = false;

var GRID_SIZE:int = 64;
var maxColumns:int = 9;
var maxRows:int = 16;

var sel:Dictionary = { "col": -1, "row": -1.0 };
var cur:Dictionary = { "row": 0.0, "section": 0 };

var del:float = 0.0;
var ms:float = 0.0;
var keyVel:float = 8;
var scrollVel:float = 10;

var song:Dictionary = {
	"lastTime": {
		"inst": 0.0,
		"voices": 0.0
	}
}

var inst:AudioStreamPlayer = null;
var voices:AudioStreamPlayer = null;

var curSection:Dictionary = {};
var sectionClipboard:Dictionary = {};
var curNotes:Dictionary = {};
var sections:Array = [];
var bfSectionFocuses:Array = [false];

var chartProperties:Dictionary = Data.defaultChartProperties.duplicate(true);
var defaultProperties:Dictionary = Data.defaultProperties.duplicate(true);

var instOnly:bool = false;
var voicesOnly:bool = false;

var selected:int = -1;

var unThread:Thread;

func spawnNote(id:int = 2, col:int = 0, row:int = 0, noteLength:float = 0.0, noteType:int = 0, nOffset:Vector2 = Vector2(0, 0), alt:bool = false, evt:String = ""):
	var note:Node2D = noteScene.instantiate();
	note.properties.alt = alt;
	note.properties.isStrum = false;
	note.properties.col = col;
	note.properties.row = row;
	note.properties.noteType = noteType;
	note.properties.noteId = id;
	note.properties.noteOffset = nOffset;
	note.properties.noteLength = noteLength;
	note.properties.evt = evt;
	note.position = defaultGridPos + Vector2(GRID_SIZE / 2, GRID_SIZE / 2);
	note.position.x += GRID_SIZE * col;
	note.position.y += GRID_SIZE * float(row / Data.rowCap);
	note.init();
	note.resizeWH(GRID_SIZE);
	note.updateOffset();
	noteTree.add_child(note);
	return note;

func createNote(id:int = 2, col:int = 0, row:float = 0):
	var data:Dictionary = defaultProperties.duplicate(true);
	data.isStrum = false;
	data.noteId = id;
	data.col = col;
	data.row = int(row * Data.rowCap);
	data.noteType = defaultProperties.noteType;
	var dataHash:int = data.hash();
	if (!curNotes.has(dataHash)):
		curNotes[dataHash] = data;
		updateProperties(dataHash);
	updateNotes();

func fillSection():
	if (cur.section + 1 > sections.size()):
		sections.append({
			"mustHitSection": true,
			"notes": {}
		});

func updateNotes():
	for note in noteTree.get_children():
		noteTree.remove_child(note);
		note.queue_free();
	
	fillSection();
	mapCurNotes();
	
	if (chartProperties.song.strip_edges() == ""):
		cur.section = 0;
		curNotes.clear();
		updateProperties(-1);
	sdl.text = sdlBase + str(cur.section);
	fpb.get_node("Btn").button_pressed = curSection.mustHitSection;
	
	for key in curNotes.keys():
		var props:Dictionary = curNotes[key];
		spawnNote(props.noteId, props.col, props.row, props.noteLength, props.noteType, props.noteOffset, props.alt, props.evt);

func setProp(dict:Dictionary, prop:String, value, isVec2:bool = false):
	if (isVec2):
		var propEnd:String = prop.substr(prop.length() - 1, 1);
		prop = prop.substr(0, prop.length() - 2).to_lower();
		var v:int = 0;
		if (propEnd == "y"):
			v += 1;
		dict[prop][v] = value;
	else:
		dict[prop] = value;
	updateNotes();

func setNoteProp(prop:String, value, isVec2:bool = false):
	if (curNotes.has(selected)):
		var note:Dictionary = curNotes[selected].duplicate(true);
		setProp(note, prop, value, isVec2);
		curNotes.erase(selected);
		selected = note.hash();
		curNotes[selected] = note;
	else:
		setProp(defaultProperties, prop, value, isVec2);

func gevtUnfocused():
	updateNotes();

func gevtChanged(txt:String):
	if (txt.length() > 65535):
		txt = txt.substr(0, 65535);
		gevti.get_node("GEVTField").text = txt;
	setNoteProp("evt", txt);

func oxEntered(data:Dictionary):
	if (data.float > Data.maxNoteLength):
		data.float = Data.maxNoteLength;
	setNoteProp("noteOffset.x", data.float, true);
	oxi.get_node("TextField").text = str(data.float);
	updateNotes();

func oyEntered(data:Dictionary):
	if (data.float > Data.maxNoteLength):
		data.float = Data.maxNoteLength;
	setNoteProp("noteOffset.y", data.float, true);
	oyi.get_node("TextField").text = str(data.float);
	updateNotes();

func lenEntered(data:Dictionary):
	if (data.float > Data.maxNoteLength):
		data.float = Data.maxNoteLength;
	if (data.float < 0.01):
		data.float = floor(data.float / 100.0) * 100.0;
	setNoteProp("noteLength", data.float);
	leni.get_node("TextField").text = str(data.float);
	updateNotes();

func aaToggled(checked:bool):
	setNoteProp("alt", checked);

func bpmEntered(data:Dictionary):
	if (data.int.normal > 2048):
		data.int.normal = 2048;
	setProp(chartProperties, "bpm", data.int.normal);
	if (inst):
		pauseSong();
	BeatHandler.setBPM(chartProperties.bpm);
	bpmi.get_node("TextField").text = str(data.int.normal);
	
func spEntered(data:Dictionary):
	if (data.float > Data.maxScrollSpeed):
		data.float = Data.maxScrollSpeed;
	if (data.float < 0.01):
		data.float = floor(data.float / 100.0) * 100.0;
	setProp(chartProperties, "scrollSpeed", data.float);
	spi.get_node("TextField").text = str(data.float);

func ioToggled(checked:bool):
	instOnly = checked;

func voToggled(checked:bool):
	voicesOnly = checked;

func updateChart():
	var songPos:float = BeatHandler.getPosition();
	var data:Array = Chart.translateP2C(songPos);
	var prevSection:int = cur.duplicate(true).section;
	cur.section = data[0];
	if (cur.section != prevSection):
		updateNotes();
	cur.row = data[1];

func toggleSong():
	if (inst):
		if (inst.playing):
			pauseSong();
		else:
			playSong();

func playSong():
	var pos:float = Chart.translateC2P([cur.section, cur.row]);
	inst.play(pos);
	if (voices):
		voices.play(pos);
	BeatHandler.songPos = pos;
	BeatHandler.startPlaying();

func pauseSong():
	BeatHandler.stopPlaying();
	inst.playing = false;
	if (voices):
		voices.playing = false;

func relPressed():
	Assets.manifest = [];
	Assets.updateManifest();
	sngi.parseData(sngi.get_node("TextField").text);
	var data:Dictionary = sngi.data;
	var songPath:String = data.str.trimmed;
	if (inst):
		if (inst.stream != null):
			Sound.stopMusic(inst.stream);
	if (voices):
		if (voices.stream != null):
			Sound.stopMusic(voices.stream);
	inst = Sound.loadMusic(songPath + "/Inst");
	chartProperties.song = songPath;
	var valid:bool = inst != null;
	if (valid):
		voices = Sound.loadMusic(songPath + "/Voices");
		BeatHandler.init(inst, chartProperties.bpm);
		cur.section = 0;
		cur.row = 0.0;
		updateNotes();
		playSong();

func sngEntered(data:Dictionary):
	if (data.str.normal.length() > 255):
		data.str.normal = data.str.normal.substr(0, 255);
	sngi.get_node("TextField").text = data.str.normal;

func lcPressed():
	FPSCounter.get_node("FPSCanvas/FPS").visible = false;
	ld.current_path = Data.curPath;
	ld.popup();

func scPressed():
	FPSCounter.get_node("FPSCanvas/FPS").visible = false;
	sd.current_path = Data.curPath;
	sd.popup();

func updateMisc():
	bpmi.get_node("TextField").text = str(chartProperties.bpm);
	spi.get_node("TextField").text = str(chartProperties.scrollSpeed);
	sngi.get_node("TextField").text = str(chartProperties.song);

func chartLoad(path:String):
	FPSCounter.get_node("FPSCanvas/FPS").visible = true;
	var f = FileAccess.open(path, FileAccess.READ);
	if (f != null && f.get_open_error() == OK):
		var chartData:PackedByteArray = f.get_buffer(f.get_length());
		f.close();
		var data:Dictionary = Chart.parse(chartData);
		chartProperties.bpm = data.bpm;
		chartProperties.scrollSpeed = data.speed;
		chartProperties.song = data.song;
		cur.section = 0;
		sections = [];
		var rawSections:Array = data.sections;
		for i in range(rawSections.size()):
			rawSections[i].notes = Chart.noteArrToNoteDict(rawSections[i].notes);
			sections.append(rawSections[i].duplicate());
			rawSections[i].clear();
		updateMisc();
		updateProperties(-1);
		updateNotes();
		relPressed();

func chartSave(path:String):
	FPSCounter.get_node("FPSCanvas/FPS").visible = true;
	var finalSections:Array = [];
	var rawSections:Array = sections.duplicate(true);
	for i in range(rawSections.size()):
		rawSections[i].notes = Chart.noteDictToNoteArr(rawSections[i].notes);
		finalSections.append(rawSections[i].duplicate());
		rawSections[i].clear();
	var chartData:PackedByteArray = Chart.conv({
		"bpm": chartProperties.bpm,
		"speed": chartProperties.scrollSpeed,
		"song": chartProperties.song,
		"sections": finalSections
	});
	var f = FileAccess.open(path, FileAccess.WRITE);
	if (f != null && f.get_open_error() == OK):
		f.store_buffer(chartData);
		f.close();

func fpToggled(checked:bool):
	curSection.mustHitSection = checked;

func csPressed():
	sectionClipboard = curSection.duplicate(true);
	updateNotes();

func psPressed():
	if (sectionClipboard.size() > 0 && sections.size() > cur.section):
		sections[cur.section] = sectionClipboard.duplicate(true);
	updateNotes();

func sncPressed():
	if (sections.size() > cur.section):
		var notes:Dictionary = curNotes.duplicate(true);
		var newNotes:Dictionary = {};
		for key in notes.keys():
			var note:Dictionary = notes[key];
			if (note.col in range(8)):
				if (note.col in range(4)):
					note.col += 4;
				else:
					note.col -= 4;
				newNotes[note.hash()] = note.duplicate(true);
				notes.erase(key);
		curSection.notes = newNotes.duplicate(true);
		updateNotes();

func snrPressed():
	if (sections.size() > cur.section):
		var notes:Dictionary = curNotes.duplicate(true);
		var newNotes:Dictionary = {};
		for key in notes.keys():
			var note:Dictionary = notes[key];
			note.row = abs((Data.maxRowCap - Data.rowCap) - note.row);
			newNotes[note.hash()] = note.duplicate(true);
			notes.erase(key);
		curSection.notes = newNotes.duplicate(true);
		updateNotes();

func init():
	InputHandler.connect("mouseMove", Callable(self, "onMove"));
	InputHandler.connect("mouseDown", Callable(self, "onClick"));
	InputHandler.connect("mouseScroll", Callable(self, "onScroll"));
	InputHandler.connect("mouseDrag", Callable(self, "onDrag"));
	InputHandler.connect("justPressed", Callable(self, "onJPressed"));
	InputHandler.connect("pressed", Callable(self, "onPressed"));
	InputHandler.connect("justReleased", Callable(self, "onReleased"));
	
	ld.connect("file_selected", Callable(self, "chartLoad"));
	sd.connect("file_selected", Callable(self, "chartSave"));
	
	bpmi.connect("entered", Callable(self, "bpmEntered"));
	spi.connect("entered", Callable(self, "spEntered"));
	iob.connect("toggled", Callable(self, "ioToggled"));
	vob.connect("toggled", Callable(self, "voToggled"));
	
	gevti.connect("changed", Callable(self, "gevtChanged"));
	gevti.connect("unfocused", Callable(self, "gevtUnfocused"));
	
	oxi.connect("entered", Callable(self, "oxEntered"));
	oyi.connect("entered", Callable(self, "oyEntered"));
	leni.connect("entered", Callable(self, "lenEntered"));
	aab.connect("toggled", Callable(self, "aaToggled"));
	
	fpb.connect("toggled", Callable(self, "fpToggled"));
		
	sngi.connect("entered", Callable(self, "sngEntered"));
	relb.connect("pressed", Callable(self, "relPressed"));
	lcb.connect("pressed", Callable(self, "lcPressed"));
	scb.connect("pressed", Callable(self, "scPressed"));
	csb.connect("pressed", Callable(self, "csPressed"));
	psb.connect("pressed", Callable(self, "psPressed"));
	sncb.connect("pressed", Callable(self, "sncPressed"));
	snrb.connect("pressed", Callable(self, "snrPressed"));
	
	fillSection();
	mapCurNotes();
	updateNotes();
	
	if (Data.song != ""):
		chartLoad("res://assets/data/charts/" + Data.song + "/1.bin");
	pass;

func _ready():
	var thread:Thread = Thread.new();
	thread.start(Callable(self, "init"));
	pass;

func validSel() -> bool:
	return sel.col >= 0 && sel.row >= 0 && sel.col < maxColumns && sel.row < maxRows;

func fixNT(props:Dictionary):
	if (props.noteType < 0):
		props.noteType = Data.noteVariants.size() - 1;
	if (props.noteType >= Data.noteVariants.size()):
		props.noteType = 0;

func mapCurNotes():
	if (sections.size() > 0):
		curSection = sections[cur.section];
		curNotes = curSection.notes;

func _process(delta):
	if (inst && voices):
		var vocalPos:float = voices.get_playback_position();
		var instPos:float = inst.get_playback_position();
		if (vocalPos <= instPos - Data.vocalResetThreshold || vocalPos >= instPos + Data.vocalResetThreshold):
			voices.seek(instPos);
	if (voices):
		if (instOnly):
			voices.volume_db = -72.0;
		else:
			voices.volume_db = 0.0;
	if (inst):
		if (voicesOnly):
			inst.volume_db = -72.0;
		else:
			inst.volume_db = 0.0;
	fixNT(defaultProperties);
	ntl.text = Data.noteVariants[defaultProperties.noteType];
	if (sections.size() > 0):
		if (selected < 0 || !curNotes.has(selected)):
			enl.text = "Default Note Properties Mode";
		else:
			enl.text = "Selected: Col " + str(curNotes[selected].col) + ", Row " + str(floor(curNotes[selected].row));
	if (cur.row < 0):
		if (cur.section > 0):
			cur.section -= 1;
			cur.row = maxRows;
			updateNotes();
		else:
			cur.row = 0;
	if (cur.row > maxRows):
		cur.section += 1;
		cur.row = 0;
		updateNotes();
	grid.position.y = gridY - (cur.row * GRID_SIZE);
	if (validSel()):
		var row:float = sel.row;
		var rowPx:float = row * GRID_SIZE;
		glowRect.position = glowPos + Vector2(sel.col * GRID_SIZE, rowPx);
		glowRect.visible = true;
	else:
		glowRect.visible = false;
		glowRect.position = disabledGlowPos;
	if (inst):
		if (inst.playing):
			updateChart();
	del = delta;
	pass;

func updateNPP(note:Dictionary):
	oxi.get_node("TextField").text = str(note.noteOffset.x);
	oyi.get_node("TextField").text = str(note.noteOffset.y);
	leni.get_node("TextField").text = str(note.noteLength);
	aab.get_node("Btn").button_pressed = note.alt;

func updateInfo(note:Dictionary):
	if (selected < 0):
		epp.visible = false;
		updateNPP(note);
	else:
		var isEvent:bool = note.col >= maxColumns - 1;
		epp.visible = isEvent;
		if (isEvent):
			gevti.get_node("GEVTField").text = note.evt;
		else:
			updateNPP(note);

func updateProperties(propHash:int):
	selected = propHash;
	var validNote:bool = selected >= 0 && curNotes.has(selected);
	if (validNote):
		updateInfo(curNotes[selected].duplicate(true));
	else:
		updateInfo(defaultProperties.duplicate(true));
	return;

func onClick(index, pos):
	if (validSel() && index == 1):
		if (ctrlMode):
			for note in noteTree.get_children():
				if (Utils.collide(pos - grid.position - defaultGridPos, Vector2(0, 0), note.position - defaultGridPos, Vector2(GRID_SIZE, GRID_SIZE))):
					updateProperties(note.properties.hash());
					return;
		elif (!altMode):
			createNote(sel.col % 4, sel.col, sel.row);

func onDrag(index, pos):
	if (validSel()):
		match (index):
			1:
				if (!ctrlMode && altMode):
					createNote(sel.col % 4, sel.col, sel.row);
			2:
				for note in noteTree.get_children():
					if (Utils.collide(pos - grid.position - defaultGridPos, Vector2(0, 0), note.position - defaultGridPos, Vector2(GRID_SIZE, GRID_SIZE))):
						var propsHash:int = note.properties.hash();
						if (curNotes.has(propsHash)):
							curNotes.erase(propsHash);
							updateNotes();
							return;

func onPressed(_key:Key):
	var key:String = OS.get_keycode_string(_key);
	match (key):
		"Up":
			cur.row -= del * keyVel;
		"Down":
			cur.row += del * keyVel;
		"Shift":
			snap = false;
		"Alt":
			altMode = true;
		"Control":
			ctrlMode = true;

func onJPressed(_key:Key):
	var key:String = OS.get_keycode_string(_key);
	match (key):
		"Q":
			defaultProperties.noteType -= 1;
		"E":
			defaultProperties.noteType += 1;
		"W":
			cur.row -= 1.0;
		"S":
			cur.row += 1.0;
		"Left":
			if (cur.section > 0):
				cur.section -= 1;
				updateNotes();
		"Right":
			cur.section += 1;
			updateNotes();
		"Space":
			toggleSong();
		"Tab":
			updateProperties(-1);
		"Enter":
			if (!ld.visible && !sd.visible):
				if (voices):
					if (voices.stream):
						Sound.stopMusic(voices.stream);
				if (inst):
					if (inst.stream):
						Sound.stopMusic(inst.stream);
						chartSave("assets/data/charts/" + chartProperties.song + "/1.bin");
						Assets.updateManifest();
						Data.loadData.queue = ["" + chartProperties.song];
						SceneTransition.switch("PlayState");

func onScroll(idx:int, pos:Vector2):
	match (idx):
		0:
			cur.row -= del * scrollVel;
		1:
			cur.row += del * scrollVel;

func onReleased(_key:Key):
	var key:String = OS.get_keycode_string(_key);
	match (key):
		"Shift":
			snap = true;
		"Alt":
			altMode = false;
		"Control":
			ctrlMode = false;

func onMove(mousePos):
		var pos:Vector2 = (mousePos - grid.position - defaultGridPos) / Vector2(GRID_SIZE, GRID_SIZE);
		if (pos.x < 0):
			sel.col = -1;
		else:
			sel.col = int(pos.x);
		sel.row = pos.y;
		if (!snap):
			sel.row -= 0.5;
		else:
			sel.row = floor(sel.row);
