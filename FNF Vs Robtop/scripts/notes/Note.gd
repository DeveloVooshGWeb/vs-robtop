extends Node2D

#signal kill(data);
#signal spawn(data);

var noteContainer:CenterContainer;
var note:AnimatedSprite;
var holdPiece:Sprite;
var holdEnd:Sprite;

var properties:Dictionary = Data.defaultProperties.duplicate(true);
var misc:Dictionary = Data.defaultMiscProperties.duplicate(true);

var size:Vector2 = Vector2.ZERO;

var noteIdAnims:PoolStringArray = ["left", "down", "up", "right"];
var strumIdAnims:PoolStringArray = ["strumLeft", "strumDown", "strumUp", "strumRight"];
var strumModifiers:PoolStringArray = ["Press", "Confirm"];

var initialized:bool = false;

var endSize:Vector2 = Vector2.ZERO;
var pieceSize:Vector2 = Vector2.ZERO;
var holdPieceScale:float = 0;

var loopConfirm:bool = false;

func normal():
	var nid:int = properties.noteId;
	if (properties.isStrum && nid in range(4)):
		loopConfirm = false;
		note.play(strumIdAnims[nid]);

func press():
	var nid:int = properties.noteId;
	if (properties.isStrum && nid in range(4)):
		note.play(strumIdAnims[nid] + strumModifiers[0]);

func confirm():
	var nid:int = properties.noteId;
	if (properties.isStrum && nid in range(4)):
		note.play(strumIdAnims[nid] + strumModifiers[1]);

func confirmLoop():
	var nid:int = properties.noteId;
	if (properties.isStrum && nid in range(4)):
		loopConfirm = true;
		note.play(strumIdAnims[nid] + strumModifiers[1]);

func resize(px:int = -1):
	if (px < 0):
		return;
	var sc:float = px / size.x;
	scale = Vector2(sc, sc);

func resizeWH(px1:int = -1, px2:int = -1):
	if (!px1 < 0):
		scale.x = px1 / size.x;
	else:
		scale.x = px2 / size.y;
	if (!px2 < 0):
		scale.y = px2 / size.y;
	else:
		scale.y = px1 / size.x;

func updateOffset():
	note.offset += properties.noteOffset * size;

func assignNodes():
	if (!noteContainer):
		noteContainer = get_node("NoteContainer");
	if (!note):
		note = noteContainer.get_node("Note");
	if (!holdPiece):
		holdPiece = get_node("HoldPiece");
	if (!holdEnd):
		holdEnd = get_node("HoldEnd");

func init(opacity:float = 1):
	assignNodes();
	if (properties.col >= 0 && properties.col < 8):
		if (properties.isStrum):
			normal();
			size = note.frames.get_frame(note.animation, note.frame).get_size();
		else:
			var nid:int = properties.noteId;
			var nt:int = properties.noteType;
			if (nt > 0):
				note.frames = load(Assets.assetPath + "res/notes/type" + String(nt) + ".res");
			if (nid in range(noteIdAnims.size())):
				var anim:String = noteIdAnims[nid];
				note.play(anim);
				size = note.frames.get_frame(note.animation, note.frame).get_size();
				if (properties.noteLength > 0.0):
					var np:String = Assets.assetPath + "png/notes/";
					holdPiece.texture = load(np + anim + "Piece.png");
					holdEnd.texture = load(np + anim + "End.png");
					pieceSize = holdPiece.texture.get_size();
					endSize = holdEnd.texture.get_size();
					holdPiece.region_rect.size = Vector2.ZERO + pieceSize;
					holdEnd.region_rect.size = Vector2.ZERO + endSize;
					holdPiece.offset.x = -(pieceSize.x / 2);
					holdPiece.scale.y = ((size.x * misc.speed) * properties.noteLength) / pieceSize.y;
					holdPieceScale = 0.0 + holdPiece.scale.y;
					holdEnd.offset.x = -(endSize.x / 2);
					holdEnd.offset.y = (holdPiece.scale.y * pieceSize.y) - (endSize.y / 2);
					holdPiece.modulate.a = 0.0 + opacity;
					holdEnd.modulate.a = 0.0 + holdPiece.modulate.a;
					holdPiece.visible = true;
					holdEnd.visible = true;
				note.offset += Data.noteVariantOffsets[nt];
	else:
		note.play("event");
		size = note.frames.get_frame(note.animation, note.frame).get_size();
	initialized = true;

func holdUpdate():
	if (holdPiece.texture && holdEnd.texture):
		var notePos:float = (position.y - misc.targetPos.y) / scale.y;
		if (sign(notePos) == -1):
			holdPiece.scale.y = ((pieceSize.y * holdPieceScale) + notePos) / pieceSize.y;
			holdEnd.modulate.a = holdPiece.modulate.a * (holdPiece.scale.y / holdPieceScale);
			holdPiece.position.y = (pieceSize.y * holdPieceScale) - (pieceSize.y * holdPiece.scale.y);
			if (holdPiece.scale.y <= 0):
				call_deferred("free");

func _ready():
	assignNodes();
	pass;

func _fixed_process(delta):
	queue_free();
	pass;