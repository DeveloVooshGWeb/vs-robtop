extends Node

var savePath:String = "rub.save";
var saveData:Dictionary = {
	"version": 1.0,
	"vault": {
		"unlocked": false,
		"entered": false
	},
	"songs": {}
};

func save():
	var f = FileAccess.open_compressed("user://" + savePath, FileAccess.WRITE, FileAccess.COMPRESSION_ZSTD);
	if (f != null && f.get_open_error() == OK):
		var json:String = JSON.stringify(save);
		f.store_string(json);
		f.close();

func _ready():
	var f = FileAccess.open_compressed("user://" + savePath, FileAccess.READ, FileAccess.COMPRESSION_ZSTD);
	if (f != null && f.get_open_error() == OK):
		var res = JSON.parse_string(f.get_as_text());
#		var test_json_conv = JSON.new()
#		test_json_conv.parse(f.get_as_text());
#		var res:JSON = test_json_conv.get_data()
		f.close();
		if (res is Dictionary):
			var result:Dictionary = res;
			if (result.has("version")):
				if (saveData.version == result.version):
					for key in saveData.keys():
						if (result.has(key)):
							if (typeof(saveData[key]) == typeof(result[key])):
								saveData[key] = result[key];
	saveData["vault"]["unlocked"] = true;
	pass;
