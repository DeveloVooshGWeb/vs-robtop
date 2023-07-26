extends Node

var disableInput:bool = false;

var speedMultiplier:float = 0.45;

var rowCap:float = 8;
var maxRowCap:float = 128;
var maxNoteLength:float = 65.535;
var maxScrollSpeed:float = 65.535;

var vocalResetThreshold:float = 0.015;

var safeFrames:int = 10;
var safeZoneOffset:float = safeFrames / 60.0;
var sigobashOffsets:Array = [safeZoneOffset * 0.85, safeZoneOffset * 0.5, safeZoneOffset * 0.35, 0.0];
var gradeAcc:Array = [100.0, 98.0, 90.0, 80.0, 75.0, 0.0];

var vec2cen:Vector2 = Vector2(960, 540);

var defaultSectionProperties:Dictionary = {
	"mustHitSection": true,
	"notes": {}
}

var defaultChartProperties:Dictionary = {
	"bpm": 130,
	"scrollSpeed": 1.0,
	"song": ""
};

var defaultProperties:Dictionary = {
	"alt": false,
	"isStrum": true,
	"col": -1,
	"row": -1,
	"noteType": 0,
	"noteId": 2,
	"noteOffset": Vector2(0.0, 0.0),
	"noteLength": 0.0,
	"evt": ""
};

var defaultMiscProperties:Dictionary = {
	"targetPos": Vector2.ZERO,
	"holdUpdate": false,
	"steps": 0.0,
	"time": 0.0,
	"speed": 1.0,
	"data": {}
}

var noteVariants:PackedStringArray = [
	"Default",
	"BadNoteDragon",
	"BadNoteFuzz",
	"BadNoteSkull",
	"BadNoteSpike",
	"CurrencyNoteCoin",
	"GoodNoteFlask",
	"GoodNoteHeart",
	"GoodNoteKey"
];

var noteTypeLabels:Dictionary = {
	0: "Note",
	1: "Bad",
	2: "Bad",
	3: "Bad",
	4: "Bad",
	5: "Coin",
	6: "Good",
	7: "Good",
	8: "Good"
};

var noteVariantOffsets:Array = [
	Vector2.ZERO,
	Vector2(0, 86),
	Vector2(0, 86),
	Vector2(0, 86),
	Vector2(0, 86),
	Vector2(0, 86),
	Vector2(0, 86),
	Vector2(0, 86),
	Vector2(0, 86),
];

var hardcodedNoteScales:Array = [
	Vector2.ONE,
	Vector2.ONE * 1.25,
	Vector2.ONE * 1.25,
	Vector2.ONE * 1.25,
	Vector2.ONE * 1.25,
	Vector2.ONE * 1.25,
	Vector2.ONE * 1.25,
	Vector2.ONE * 1.25,
	Vector2.ONE * 1.25
]

var noteSize:int = 164;

var icons:Dictionary = {
	"enough": ["robtop", "bf"]
}

var song:String = "";

var loadData:Dictionary = {
	"difficulty": 1,
	"queue": ["warning"],
	"story": false
};

# Platformer shiz time
var platData:Dictionary = {
	"theme": Color8(70, 60, 242, 255)
}

# Packs
var packData:Array = [
	{
		"pack": "GWeb",
		"color": Color8(0, 255, 125, 255),
		"songs": 8,
		"diff": 8
	},
	{
		"pack": "Valen",
		"color": Color8(0, 210, 255, 255),
		"songs": 4,
		"diff": 2
	},
	{
		"pack": "Gamemaster",
		"color": Color8(200, 225, 125, 255),
		"songs": 6,
		"diff": 4
	}
];

# Selection Data
var selectionData:Dictionary = {
	"id": "GWeb",
	"songs": [
		"Rush",
		"Vault",
		"Chip",
		"Harm",
		"Warning",
		"Enough",
		"Loop",
		"Out"
	]
};

# Game Over State
var goState:int = 1;

func ColorHSV(h:float = 360, s:float = 0, v:float = 100, a:float = 1) -> Dictionary:
	# stol-
	# i mean borrowed and modified from https://www.reddit.com/r/godot/comments/ajll6t/create_color_from_hsv_values/
	
	# original comments:
	# based on code at
	# http://stackoverflow.com/questions/51203917/math-behind-hsv-to-rgb-conversion-of-colors
	
	if (h > 360):
		h = 360;
	if (h < -360):
		h = -360;
	if (s > 100):
		s = 100;
	if (v > 100):
		v = 100;
	if (s < 0):
		s = 0;
	if (v < 0):
		v = 0;
	if (a > 1):
		a = 1;
	if (a < 0):
		a = 0;
	
	var hsv:Array = [0 + h, 0 + s, 0 + v];
	
	h /= 360;
	s /= 100;
	v /= 100;
	
	var r:float = 0;
	var g:float = 0;
	var b:float = 0;

	var i:float = floor(h * 6);
	var f:float = h * 6 - i;
	var p:float = v * (1 - s);
	var q:float = v * (1 - f * s);
	var t:float = v * (1 - (1 - f) * s);

	match (int(i) % 6):
		0:
			r = v;
			g = t;
			b = p;
		1:
			r = q;
			g = v;
			b = p;
		2:
			r = p;
			g = v;
			b = t;
		3:
			r = p;
			g = q;
			b = v;
		4:
			r = t;
			g = p;
			b = v;
		5:
			r = v;
			g = p;
			b = q;
	
	var dict:Dictionary = {
		"rgb": Color(r, g, b, a),
		"hsv": hsv
	};
	
	return dict;

var curPath:String = "";

func _ready():
	var curPathArr:PackedStringArray = OS.get_executable_path().split("/");
	curPathArr.remove_at(curPathArr.size() - 1);
	curPath = "/".join(curPathArr) + "/";
	pass
