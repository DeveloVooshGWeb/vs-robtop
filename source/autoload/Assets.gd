extends Node

var assets:Dictionary = {};
var manifest:PackedStringArray = [];

var assetPath:String = "res://assets/";
# var defaultManifestPath:String = assetPath + "manifest/manifest.txt";

func errNotFound():
	print("ERR: Asset Not Found!");

func fetch(path:String):
#	path = path.to_lower();
	for i in range(manifest.size()):
		var curFilePath:String = manifest[i];
		var absPath:String = assetPath + curFilePath;
		if (curFilePath.to_lower().find(path.to_lower()) != -1):
			if (absPath.ends_with(".sec")):
				var f = FileAccess.open(absPath, FileAccess.READ);
				if (f != null && f.get_open_error() == OK):
					var secArr = [f.get_buffer(f.get_length()), absPath];
					f.close();
					return secArr;
				else:
					errNotFound();
			elif (!assets.has(curFilePath)):
				assets[curFilePath] = load(absPath);
			if (assets[curFilePath] == null):
				var f = FileAccess.open(absPath, FileAccess.READ);
				if (f != null && f.get_open_error() == OK):
					assets[curFilePath] = f.get_buffer(f.get_length());
					f.close();
			return [assets[curFilePath], absPath];
	return [null, ""];

func extify(a:String = "", b:String = "") -> String:
	return b + "/" + a + "." + b;

func getBytes(path:String = "", key:PackedByteArray = []) -> PackedByteArray:
#	path = path.to_lower();
	for i in range(manifest.size()):
		var curFilePath:String = manifest[i];
		if (curFilePath.to_lower().find(path.to_lower()) != -1):
			var absPath:String = assetPath + curFilePath;
			var f = FileAccess.open(absPath, FileAccess.READ);
			if (f != null && f.get_open_error() == OK):
				var byteArray:PackedByteArray = f.get_buffer(f.get_length());
				f.close();
				if (absPath.ends_with(".sec")):
					byteArray = AES.decrypt(key, byteArray);
				return byteArray;
			else:
				errNotFound();
	return PackedByteArray([]);

func getText(path:String = "", utf8:bool = false, lf:bool = false) -> String:
	var byteArray:PackedByteArray = getBytes("data/" + path + ".txt");
	var txtData:String = byteArray.get_string_from_ascii();
	if (utf8):
		txtData = byteArray.get_string_from_utf8();
	if (lf):
		return str("").join(txtData.split("\r"));
	return txtData;

func getDat(path:String = "", utf8:bool = false, lf:bool = false) -> String:
	var byteArray:PackedByteArray = getBytes("data/" + path + ".dat");
	var txtData:String = byteArray.get_string_from_ascii();
	if (utf8):
		txtData = byteArray.get_string_from_utf8();
	if (lf):
		return str("").join(txtData.split("\r"));
	return txtData;

func getSecText(path:String = "", utf8:bool = false, lf:bool = false, key:PackedByteArray = []) -> String:
	var byteArray:PackedByteArray = getBytes("sec/data/" + path + ".sec", key);
	var txtData:String = byteArray.get_string_from_ascii();
	if (utf8):
		txtData = byteArray.get_string_from_utf8();
	if (lf):
		return str("").join(txtData.split("\r"));
	return txtData;

func getSpriteFrames(path:String = "") -> SpriteFrames:
	var res = fetch(extify(path, "res"));
	if (res[0] == null || res.size() != 2):
		return null;
	var p:String = res[1];
	if (p.length() < 4):
		return null;
	var pExt:String = p.substr(p.length() - 4);
	if (pExt != ".res"):
		return null;
	return res[0];

func getAudio(path:String = "", key:PackedByteArray = []) -> AudioStreamOggVorbis:
	var res = fetch(extify(path, "ogg"));
	if (res[0] == null):
		res = fetch(extify("ogg/" + path, "sec"));
	if (res[0] == null || res.size() != 2): 
		return null;
	var p:String = res[1];
	if (p.length() < 4):
		return null;
	var pExt:String = p.substr(p.length() - 4);
	match (pExt):
		".sec":
			# New Idea
			var ogg:AudioStreamOggVorbis = AudioStreamOggVorbis.new();
			var oggPacSeq:OggPacketSequence = OggPacketSequence.new();
			if (!OggLoader.cached(path)):
				var oggDecoded:PackedByteArray = AES.decrypt(key, res[0]);
				var result:bool = OggLoader.proc(p, oggDecoded);
	#			for i in range(1000):
	#				print(OggLoader.get_ogg_metadata(oggDecoded));
			oggPacSeq.granule_positions = OggLoader.get_granule_positions(p);
			oggPacSeq.packet_data = OggLoader.get_packet_data(p);
			ogg.packet_sequence = oggPacSeq;
			return ogg;
		".ogg":
			if (res[0] is PackedByteArray):
				var ogg:AudioStreamOggVorbis = AudioStreamOggVorbis.new();
				var oggPacSeq:OggPacketSequence = OggPacketSequence.new();
				if (!OggLoader.cached(path)):
					var result:bool = OggLoader.proc(path, res[0]);
				oggPacSeq.granule_positions = OggLoader.get_granule_positions(p);
				oggPacSeq.packet_data = OggLoader.get_packet_data(p);
				ogg.packet_sequence = oggPacSeq;
				return ogg;
			return res[0];
		_:
			return null;

func getPng(path:String = "", key:PackedByteArray = []) -> Image:
	var res = fetch(extify(path, "png"));
	if (res[0] == null):
		res = fetch(extify("png/" + path, "sec"));
	if (res[0] == null || res.size() != 2):
		return null;
	var p:String = res[1];
	if (p.length() < 4):
		return null;
	var pExt:String = p.substr(p.length() - 4);
	match pExt:
		".sec":
			var imgArr:PackedByteArray = AES.decrypt(key, res[0]);
			var img:Image = Image.new();
			var e:bool = img.load_png_from_buffer(imgArr) != OK;
			if (e):
				return null;
			return img;
		".png":
			return res[0];
		_:
			return null;

func getBmp(path:String = "", key:PackedByteArray = []) -> Image:
	var res = fetch(extify(path, "bmp"));
	if (res[0] == null):
		res = fetch(extify("bmp/" + path, "sec"));
	if (res[0] == null || res.size() != 2):
		return null;
	var p:String = res[1];
	if (p.length() < 4):
		return null;
	var pExt:String = p.substr(p.length() - 4);
	match pExt:
		".sec":
			var imgArr:PackedByteArray = AES.decrypt(key, res[0]);
			var img:Image = Image.new();
			var e:bool = img.load_bmp_from_buffer(imgArr) != OK;
			if (e):
				return null;
			return img;
		".bmp":
			return res[0];
		_:
			return null;

func getJpg(path:String = "", key:PackedByteArray = []) -> Image:
	var res = fetch(extify(path, "jpg"));
	if (res[0] == null):
		res = fetch(extify("jpg/" + path, "sec"));
	if (res[0] == null || res.size() != 2):
		return null;
	var p:String = res[1];
	if (p.length() < 4):
		return null;
	var pExt:String = p.substr(p.length() - 4);
	match pExt:
		".sec":
			var imgArr:PackedByteArray = AES.decrypt(key, res[0]);
			var img:Image = Image.new();
			var e:bool = img.load_jpg_from_buffer(imgArr) != OK;
			if (e):
				return null;
			return img;
		".jpg":
			return res[0];
		_:
			return null;

func getTga(path:String = "", key:PackedByteArray = []) -> Image:
	var res = fetch(extify(path, "tga"));
	if (res[0] == null):
		res = fetch(extify("tga/" + path, "sec"));
	if (res[0] == null || res.size() != 2):
		return null;
	var p:String = res[1];
	if (p.length() < 4):
		return null;
	var pExt:String = p.substr(p.length() - 4);
	match pExt:
		".sec":
			var imgArr:PackedByteArray = AES.decrypt(key, res[0]);
			var img:Image = Image.new();
			var e:bool = img.load_tga_from_buffer(imgArr) != OK;
			if (e):
				return null;
			return img;
		".tga":
			return res[0];
		_:
			return null;

func getWebp(path:String = "", key:PackedByteArray = []) -> Image:
	var res = fetch(extify(path, "webp"));
	if (res[0] == null):
		res = fetch(extify("webp/" + path, "sec"));
	if (res[0] == null || res.size() != 2):
		return null;
	var p:String = res[1];
	if (p.length() < 4):
		return null;
	var pExt:String = p.substr(p.length() - 4);
	match pExt:
		".sec":
			var imgArr:PackedByteArray = AES.decrypt(key, res[0]);
			var img:Image = Image.new();
			var e:bool = img.load_webp_from_buffer(imgArr) != OK;
			if (e):
				return null;
			return img;
		"webp":
			if (p[p.length() - 5] != "."):
				return null;
			return res[0];
		_:
			return null;

func getScene(path:String = "") -> PackedScene:
	return load("res://scenes/" + path + ".tscn");

func getStage(path:String = "") -> PackedScene:
	return getScene("stages/" + path);

func _processManifest(folder:String = "") -> Array:
	var files:Array = [];
	var dir:DirAccess = DirAccess.open(folder);
	if (dir.get_open_error() == OK):
		if (dir.list_dir_begin() == OK):# TODOGODOT4 fill missing arguments https://github.com/godotengine/godot/pull/40547
			var filePath:String = dir.get_next();
			while (filePath != ""):
				if (dir.current_is_dir()):
					files.append_array(_processManifest(folder + filePath + "/"));
				else:
					files.append(folder + filePath);
				filePath = dir.get_next();
	return files;

func updateManifest():
	for file in _processManifest("assets/"):
#		var fileName:String = file.substr("assets/".length()).to_lower();
		var fileName:String = file.substr("assets/".length());
		manifest.append(fileName);

func _ready():
	updateManifest();
	pass;
