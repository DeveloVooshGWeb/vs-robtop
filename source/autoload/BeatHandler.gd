extends Node

# Hey Coders I Have A Funny Joke :D
# I Was Originally Gonna Name This BeatStep Handler
# Before I Finally Named It To BeatHandler
# But It Was Too Long So Guess What I Was Going To Name It?
# BSHandler Haha Get It Cause [B, S] Bullshit HAHAHAH
# That Was A Poorly Made Joke D:

signal beatHit(b);
signal stepHit(s);

var bpm:int = 130;

var beats:int = 0;
var steps:int = 0;

var prevBeats:int = 0;
var prevSteps:int = 0;

var absBeats:float = 0;
var absSteps:float = 0;

var song:AudioStreamPlayer = null;
var songFinished:bool = false;

var playing:bool = false;

var beatSecs:float = 0;
var stepSecs:float = 0;

func setBPM(BPM:int = 130):
	bpm = BPM;
	beatSecs = (60.0 / bpm);
	stepSecs = beatSecs / 4.0;

func init(SONG:AudioStreamPlayer = null, BPM:int = 130):
	beats = 0;
	steps = 0;
	prevBeats = 0;
	prevSteps = 0;
	songFinished = false;
	song = SONG;
	setBPM(BPM);

func songInvalid() -> bool:
	if (song == null):
		return true;
	if (song.stream == null):
		return true;
	return !song.playing;

func getPosition() -> float:
	if (songInvalid()):
		return 0.0;
	return song.get_playback_position();

func getLength() -> float:
	if (songInvalid()):
		return 0.0;
	return song.stream.get_length();

func _ready():
	pass;

func _process(delta):
	if (!songInvalid()):		
		var songPos:float = getPosition();
		var songLen:float = getLength();
	
		var songMins:float = songPos / 60;
		
		absSteps = (bpm * 4) * songMins;
		absBeats = absSteps / 4;
		
		steps = floor(absSteps)
		beats = floor(absBeats);
		
		if (steps != prevSteps):
			emit_signal("stepHit", steps);
		if (beats != prevBeats):
			emit_signal("beatHit", beats);
		
		prevSteps = steps;
		prevBeats = beats;
		return;
	if (songFinished):
		song = null;
		bpm = 130;
	pass;
