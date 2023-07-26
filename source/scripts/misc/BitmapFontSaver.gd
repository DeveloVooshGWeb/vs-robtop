extends Control

var fontPath:String = "goldPusab";
var bitmapFont:FontFile;

func _ready():
	bitmapFont = FontFile.new();
	bitmapFont.add_texture(load("res://assets/fonts/" + fontPath + ".png"));
	bitmapFont.create_from_fnt("res://assets/fonts/" + fontPath + ".fnt");
	ResourceSaver.save("res://assets/fonts/" + fontPath + ".res", bitmapFont);
	pass;
