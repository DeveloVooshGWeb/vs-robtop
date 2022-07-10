extends Control

var fontPath:String = "goldPusab";
var bitmapFont:BitmapFont;

func _ready():
	bitmapFont = BitmapFont.new();
	bitmapFont.add_texture(load("res://assets/fonts/" + fontPath + ".png"));
	bitmapFont.create_from_fnt("res://assets/fonts/" + fontPath + ".fnt");
	ResourceSaver.save("res://assets/fonts/" + fontPath + ".res", bitmapFont);
	pass;
