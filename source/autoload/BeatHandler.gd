extends Node

# Hey Coders! I Have A Funny And Totally Not Rushed Joke :D
# I Was Originally Gonna Name This BeatStep Handler
# Before I Finally Named It To BeatHandler
# But It Was Too Long So Guess What I Was Going To Name It?
# BSHandler Haha Get It Cause [B, S] BullShit HAHAHAH
# That Was A Poorly Made Joke D:

signal finished();
signal sectionHit(sec);
signal beatHit(b);
signal stepHit(s);

var bpm:int = 130;

var sections:int = 0;
var beats:int = 0;
var steps:int = 0;

var prevSections:int = -1;
var prevBeats:int = -1;
var prevSteps:int = -1;

var song:AudioStreamPlayer = null;
var songFinished:bool = false;

var playing:bool = false;

var sectionSecs:float = 0;
var beatSecs:float = 0;
var stepSecs:float = 0;

var songPos:float = 0;
var startedPlaying:bool = false;

func setBPM(BPM:int = 130):
	bpm = BPM;
	sectionSecs = (60.0 / bpm) * 4.0;
	beatSecs = sectionSecs / 4.0;
	stepSecs = beatSecs / 4.0;

func init(SONG:AudioStreamPlayer = null, BPM:int = 130):
	startedPlaying = false;
	beats = 0;
	steps = 0;
	prevBeats = 0;
	prevSteps = 0;
	songFinished = false;
	song = SONG;
	if (song != null):
		if (song.is_connected("finished", Callable(self, "finishedF"))):
			song.disconnect("finished", Callable(self, "finishedF"));
		song.connect("finished", Callable(self, "finishedF"));
	songFinished = false;
	setBPM(BPM);

func songInvalid() -> bool:
	if (song == null):
		return true;
	if (song.stream == null):
		return true;
	return !song.playing;

func getSteps() -> float:
	return getPosition() / stepSecs;

func getBeats() -> float:
	return getPosition() / stepSecs;

func getPosition() -> float:
	return songPos;

func getLength() -> float:
	if (songInvalid()):
		return 0.0;
	return song.stream.get_length();

func startPlaying():
	startedPlaying = true;
	pass;

func stopPlaying():
	startedPlaying = false;
	pass;

func finishedF():
	song = null;
	songFinished = true;
	emit_signal("finished");
	pass;

func _ready():
	pass;

func _process(delta):
	if (startedPlaying):
		songPos += delta;
	if (!songInvalid()):
		var actualPos:float = song.get_playback_position();
		if (abs(round(actualPos - songPos)) >= Data.vocalResetThreshold):
			songPos = actualPos;
		var songLen:float = getLength();
#		var songMins:float = songPos / 60;
#		steps = bpm * songMins * 4.0;
#		beats = bpm * songMins;
#		sections = (bpm * songMins) / 4.0;
		steps = songPos / stepSecs;
		beats = songPos / beatSecs;
		sections = songPos / sectionSecs;
		
		if (steps != prevSteps):
			emit_signal("stepHit", steps);
		if (beats != prevBeats):
			emit_signal("beatHit", beats);
		if (sections != prevSections):
			emit_signal("sectionHit", sections);
		
		prevSteps = steps;
		prevBeats = beats;
		prevSections = sections;
	pass;
