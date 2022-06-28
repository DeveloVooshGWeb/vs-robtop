extends Node

func _ready():
	$GCTimer.connect("timeout", self, "_gc");

func loadSound(sound:String = "", gain:float = 0, key:PoolByteArray = [], bus:String = "Sounds") -> AudioStreamPlayer:
	sound = "sounds/" + sound;
	var target:AudioStreamOGGVorbis = Assets.getAudio(sound, key);
	if (target == null):
		target = Assets.getAudio(sound, key);
	if (target == null):
		print("ERROR: Could not play sound: ", sound);
		return null;
	target.loop = false;
		
	var snd:AudioStreamPlayer = AudioStreamPlayer.new();
	snd.bus = bus;
	snd.stream = target;
	snd.volume_db = gain;
	$Sounds.add_child(snd);
	return snd;

func play(sound:String = "", gain:float = 0, key:PoolByteArray = [], bus:String = "Sounds") -> AudioStreamPlayer:
	var snd:AudioStreamPlayer = loadSound(sound, gain, key, bus);
	snd.play();
	return snd;

func loadMusic(sound:String = "", gain:float = 0, loop:bool = true, key:PoolByteArray = [], bus:String = "Music") -> AudioStreamPlayer:
	sound = "songs/" + sound;
	var target:AudioStreamOGGVorbis = Assets.getAudio(sound, key);
	if (target == null):
		target = Assets.getAudio(sound, key);
	if (target == null):
		print("ERROR: Could not play sound: ", sound);
		return null;
	target.loop = loop;
	
	var snd = AudioStreamPlayer.new();
	snd.bus = bus;
	snd.stream = target;
	snd.volume_db = gain;
	$Songs.add_child(snd);
	return snd;

func playMusic(sound:String = "", gain:float = 0, loop:bool = true, key:PoolByteArray = [], bus:String = "Music") -> AudioStreamPlayer:
	var snd:AudioStreamPlayer = loadMusic(sound, gain, loop, key, bus);
	snd.play();
	return snd;
	
func stopMusic(stream:AudioStream):
	for i in $Songs.get_children():
		if (i):
			if (i.name.begins_with("@")):
				if (i.stream == stream):
					i.stop()

func stopSound(stream:AudioStream):
	for i in $Sounds.get_children():
		if (i):
			if (i.name.begins_with("@")):
				if (i.stream == stream):
					i.stop()

func stopAll():
	for i in get_children():
		if (i):
			if (i.name.begins_with("@")):
				i.stop()

func setGCTime(GarbageCollectionWait):
	$GCTimer.wait_time = GarbageCollectionWait

func _gc():
	for i in $Sounds.get_children():
		if (i):
			if (i.name.begins_with("@")):
				if (i.playing != true):
					i.queue_free();
	for i in $Songs.get_children():
		if (i):
			if (i.name.begins_with("@")):
				if (i.playing != true && !i.stream.loop):
					if (i == BeatHandler.song):
						BeatHandler.song = null;
						BeatHandler.songFinished = true;
					i.queue_free();
					
func findSound(stream):
	for i in $Sounds.get_children():
		if (i):
			if (i.name.begins_with("@")):
				if (i.stream == stream):
					return i;

func findSong(stream:AudioStreamOGGVorbis):
	for i in $Songs.get_children():
		if (i):
			print(i.name);
			if (i.name.begins_with("@")):
				if (i.stream == stream):
					return i;
