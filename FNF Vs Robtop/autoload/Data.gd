extends Node

var disableInput:bool = false;

var speedMultiplier:float = 0.45;

var rowCap:float = 8;
var maxRowCap:float = 128;
var maxNoteLength:float = 65.535;
var maxScrollSpeed:float = 65.535;

var vocalResetThreshold:float = 0.05;

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
	"time": 0.0,
	"speed": 1.0,
	"data": {}
}

var noteVariants:PoolStringArray = [
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

var noteSize:int = 164;

var icons:Dictionary = {
	"enough": ["robtop", "bf"]
}

var song:String = "";

var loadData:Dictionary = {
	"difficulty": 1,
	"queue": ["warning"]
};

# Platformer shiz time
var platData:Dictionary = {
	"theme": Color8(70, 60, 242, 255)
}

var curPath:String = "";

func _ready():
	var curPathArr:PoolStringArray = OS.get_executable_path().split("/");
	curPathArr.remove(curPathArr.size() - 1);
	curPath = curPathArr.join("/") + "/";
	pass
