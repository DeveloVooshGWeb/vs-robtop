extends Node

var modulePath:String = "res://modules/";
var fileExt:String = ".module";

func listModules(root:String) -> PackedStringArray:
	var files:PackedStringArray = [];
	var dir:DirAccess = DirAccess.open(root);
	if (DirAccess.get_open_error() == OK):
		if (dir.list_dir_begin() == OK):# TODOGODOT4 fill missing arguments https://github.com/godotengine/godot/pull/40547
			var filePath:String = dir.get_next();
			while (filePath != ""):
				if (dir.current_is_dir()):
					files.append_array(listModules(root + filePath + "/"));
				elif (filePath.ends_with(fileExt)):
					files.append(root + filePath);
				filePath = dir.get_next();
	files.sort();
	return files;

func read(register_module:Callable) -> void:
	var paths:PackedStringArray = listModules(modulePath);
	var f:FileAccess;
	for path in paths:
		var pathArr:PackedStringArray = path.split("/");
		if (pathArr.size() > 0):
			f = FileAccess.open(path, FileAccess.READ);
			var code:String = f.get_as_text(true).strip_edges(true, true);
			f.close();
			var isSingleton:bool = false;
			var className:String = "Node";
			if (code.begins_with("# Singleton\nextends ")):
				className = code.split("\n")[1].split(" ")[1].split("\n")[0];
				isSingleton = true;
			elif (code.begins_with("extends ")):
				className = code.split(" ")[1].split("\n")[0];
			register_module.call(className, pathArr[pathArr.size() - 1].split(fileExt)[0].substr(3), code, isSingleton);
		# var codeLines:PackedStringArray = f.get_as_text(true).split("\n");
		# f.close();
		# var tempLines:PackedStringArray = [];
		# var mode:int = 0;
		# for line in codeLines:
		# 	match (mode):
		# 		0:
		# 			var lineSubStr:String = line.strip_edges().substr(0, 4);


func _ready():
	pass
