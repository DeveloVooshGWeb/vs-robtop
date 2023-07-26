extends Node

var b:int = 1;
var c:int = 3;

var module;

func weird(a:String = "", d:int = 0, c:String = ""):
	print(c);
	print("alol ", d);

func _set(property:StringName, value:Variant):
	var j:bool = true;
	for i in get_property_list():
		if (i["name"] == property):
			j = false;
			break;
	if (j):
		print("lmfao");
		b += 10;

func _get(property:StringName):
	if (property == "aaa"):
		return weird.bind("helo");
	elif (property == "ba"):
		return b;

func _ready():
	# var f:FileAccess = FileAccess.open("res://modules/print.module", FileAccess.READ);
	# if (f.get_open_error() == OK):
	# 	var code:String = f.get_as_text();
	# 	f.close();
	# 	var error:Error = expression.parse(code);
	# 	if (error != OK):
	# 		print(expression.get_error_text());
	# 		print("smh");
	# 		return;
	# 	var result:Variant = expression.execute([], self);
	# 	if (!expression.has_execute_failed()):
	# 		print(result);
	# 		print("letsa go!");
	# 		print(Callable(self, "hello").call());
	# 		print(get("th"));
	# print("alol");
	# var a = weird.bind("helo");
	# a.call("", 0);
	
	# var expression := Expression.new();
	# set("aaa", 2);
	# if (expression.parse("set(\"a\", 0);\na + 2") != OK):
	# 	print(expression.get_error_text());
	# 	print("smh");
	# 	return;
	# var result = expression.execute([], self);
	# if (!expression.has_execute_failed()):
	# 	print(result);
	# 	print("woohoo");

	var f:FileAccess = FileAccess.open("res://modules/test.module", FileAccess.READ);
	if (FileAccess.get_open_error() == OK):
		var code:String = f.get_as_text(true).strip_edges();
		f.close();
		var script := GDScript.new();
		script.set_source_code(code);
		# script.set("extend", self);
		script.reload();
		if (code.begins_with("extends ")):
			var className:String = code.split(" ")[1].split("\n")[0];
			print(className);
			module = ClassDB.instantiate(className);
			module.set_script(script);
			add_child(module);
			module.set_owner(self);
	pass

func _process(delta):
	module.call("lol");
	pass
