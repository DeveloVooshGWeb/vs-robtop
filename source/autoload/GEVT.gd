extends Node

var defaultDelimiter:String = " ";
var delimiters:Array = [["\"", "\""], ["[", "]"], ["{", "}"]];

func parse(code:String) -> Array:
	var events:Array = [];
	var lines:PoolStringArray = code.split("\r").join("").split("\n");
	for line in lines:
		line = line.strip_edges();
		if (line != "" && !line.begins_with("#")):
			line += " ";
			var function:String = "";
			var args:Array = [];
			var text:String = "";
			var delimiterProperties:Dictionary = {
				"delimiter": "",
				"flag": 0
			};
			for i in range(line.length()):
				var character:String = line[i];
				text += character;
				for delimiter in delimiters:
					if (delimiter.has(delimiterProperties.delimiter) || delimiterProperties.delimiter == ""):
						var curFlag:int = 0 + delimiterProperties.flag;
						if (curFlag == 0):
							curFlag = 1;
						match (curFlag):
							1:
								var curDelimiter:String = delimiter[0];
								if (text.ends_with(" " + curDelimiter)):
									text = "";
									delimiterProperties.delimiter = "" + curDelimiter;
									delimiterProperties.flag = 2;
							2:
								var curDelimiter:String = delimiter[1];
								if (text.ends_with(curDelimiter + " ")):
									text = text.strip_edges().substr(0, text.length() - curDelimiter.length());
									args.append(str2var(delimiter[0] + text + delimiter[1]));
									text = "";
									delimiterProperties.delimiter = "";
									delimiterProperties.flag = 0;
				if (delimiterProperties.delimiter == "" && text.ends_with(" ")):
					text = text.strip_edges();
					if (text != ""):
						if (args.size() <= 0):
							function = "" + text;
						args.append(str2var("" + text));
						text = "";
			if (text != ""):
				if (args.size() <= 0):
					function = "" + text;
				args.append("" + text);
				text = "";
			args.pop_front();
			events.append({
				"function": function,
				"args": args
			});
	print(events);
	return events;

func _ready():
	pass;
