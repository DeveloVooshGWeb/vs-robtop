extends Node2D

@onready var vault:Node2D = get_node("Vault");
@onready var input:LineEdit = vault.get_node("Input");
@onready var dialogue:Label = vault.get_node("Dialogue");
@onready var spooky:Node2D = vault.get_node("Spooky");
@onready var back:Sprite2D = get_node("Back");
var backSize:Vector2 = Vector2.ZERO;
var backSelected:bool = false;
var spookySelected:bool = false;

var vaultData:Dictionary = {
	"code": "",
	"hash": 0,
	"hashes": [	
		"fb04cc32e317031782a9a7c847b912ce235aa7dd5dc9e29becc4d93fe9d07eef",
		"5948f86b9403de7f2e4f66994842aa3a9348443a0721eb5f35f4ee8898cb26ed",
		"725b4989928c75b4b7cad88b8b432a3f11a410fc70c05f2a9357293d6dc4843f",
		"ef52489735cd91c8f01cd5022790af7bea528dc2a2119cb7ae34287cdf493ba6",
		"6ef1215b29bc56713ef15919df5c3cd8a38c0696528ae623c3a5971691fa98b2",
		"b04dda1ea5dede39b2060a593438e9556cd0c63b41239aa64dd932117482319c"
	],
	"dialogue": {
		"line": -1,
		"data": [],
		"fail": [],
		"cache": [],
		"hints": [
			"00",
			"01",
			"02",
			"03",
			"04",
			"05"
		],
		"hintColor": Color8(10, 239, 234, 255)
	}
};

var rng:RandomNumberGenerator = RandomNumberGenerator.new();

var spookyTweener:CustomFloatTweener;
var backTweener:CustomFloatTweener;

func parseDialogue(dialogueContent:String) -> Array:
	var dialogueData:Array = [];
	var dialogues:PackedStringArray = dialogueContent.split("\n\n");
	for dialogue in dialogues:
		var dialogueTree:PackedStringArray = dialogue.split("\n");
		if (dialogueTree.size() >= 2):
			var face:String = dialogueTree[0].to_lower();
			dialogueTree.remove_at(0);
			var dialogueText:String = "\n".join(dialogueTree);
			dialogueData.append([face, dialogueText]);
	return dialogueData;

func cacheDialogue():
	for hint in vaultData.dialogue.hints:
		vaultData.dialogue.cache.append(parseDialogue(Assets.getDat("vault/" + hint, false, true)));
	pass;

var readingCodeDialogue:bool = false;

func shuffleDialogue():
	readingCodeDialogue = false;
	dialogue.modulate = Color8(255, 255, 255, 255);
	vaultData.dialogue.data = [];
	for i in range(10):
		var failItem:Array = [];
		var firstShuffle:bool = true;
		while (vaultData.dialogue.data.find(failItem) != -1 || firstShuffle):
			firstShuffle = false;
			failItem = vaultData.dialogue.fail[rng.randi_range(0, vaultData.dialogue.fail.size() - 1)];
		vaultData.dialogue.data.append(failItem);
	var maxRange:int = vaultData.dialogue.cache.size() - 1;
	if (maxRange >= 0):
		vaultData.dialogue.data += vaultData.dialogue.cache[rng.randi_range(0, maxRange)];
	else:
		print("grrr did you tamper with the randomizing system again?");
		print("cause im going to delete your save file");
		print("- Spooky");

func updateDialogue():
	vaultData.dialogue.line += 1;
	if (vaultData.dialogue.line >= vaultData.dialogue.data.size()):
		vaultData.dialogue.line = 0;
		shuffleDialogue();
	if (vaultData.dialogue.data[vaultData.dialogue.line].size() == 2):
		if (vaultData.dialogue.fail.find(vaultData.dialogue.data[0]) != -1 && vaultData.dialogue.line >= 10):
			dialogue.modulate = vaultData.dialogue.hintColor;
		var diaData:Array = vaultData.dialogue.data[vaultData.dialogue.line];
		spooky.play(diaData[0]);
		dialogue.text = diaData[1];

func _onPressed(index:int, pos:Vector2):
	if (index == 1):
		if (SaveManager.saveData.vault.unlocked):
			if (Utils.collide(pos, Vector2.ZERO, spooky.position, spooky.size)):
				spookySelected = true;
		if (Utils.collide(pos, Vector2.ZERO, back.position, backSize)):
			backSelected = true;

func _onDrag(index:int, pos:Vector2):
	if (index == 1):
		if (SaveManager.saveData.vault.unlocked):
			if (spookySelected):
				if (Utils.collide(pos, Vector2.ZERO, spooky.position, spooky.size)):
					if (spookyTweener.inverted):
						spookyTweener.play();
				else:
					if (!spookyTweener.inverted):
						spookyTweener.play_invert();
		if (Utils.collide(pos, Vector2.ZERO, back.position, backSize)):
			if (backTweener.inverted):
				backTweener.play();
		else:
			if (!backTweener.inverted):
				backTweener.play_invert();

func _onReleased(index:int, pos:Vector2):
	if (index == 1):
		if (SaveManager.saveData.vault.unlocked):
			if (!spookyTweener.inverted):
				spookyTweener.play_invert();
			if (spookySelected):
				processVault();
				spookySelected = false;
		if (!backTweener.inverted):
			backTweener.play_invert()
		if (backSelected):
			SceneTransition.switch("MainMenuState", true);
			backSelected = false;

func processVault():
	input.text = input.text.to_lower();
	if (readingCodeDialogue):
		updateDialogue();
	else:
		if (vaultData.code != input.text && input.text != ""):
			vaultData.code = "" + input.text;
			vaultData.hash = vaultData.hashes.find(hashData(vaultData.code.to_ascii_buffer()));
		match (input.text):
			"":
				updateDialogue();
			_:
				match (vaultData.hash):
					0:
						vaultData.invalid = false;
						var key:PackedByteArray = input.text.to_utf8_buffer();
						for i in range(32 - key.size()):
							key.append(2);
#						var f:FileAccess = FileAccess.open("res://assets/sec/data/vault/" + vaultData.hashes[vaultData.hash] + ".sec", FileAccess.WRITE);
#						if (f.get_open_error() == OK):
#							f.store_buffer(AES.encrypt(key, Assets.getDat("vault/stayinyourcoma", false, true).to_utf8_buffer()));
#							f.close();
						readingCodeDialogue = true;
						vaultData.dialogue.data = parseDialogue(Assets.getBytes("sec/data/vault/" + vaultData.hashes[vaultData.hash] + ".sec", key).get_string_from_utf8());
						vaultData.dialogue.line = -1;
						dialogue.modulate = Color8(255, 255, 255, 255);
						updateDialogue();
					_:
						vaultData.code = "";
						vaultData.hash = -1;
						vaultData.dialogue.line = -1;
						shuffleDialogue();
						updateDialogue();
	input.text = "";

func hashData(data:PackedByteArray) -> String:
	var key:PackedByteArray = [];
	if (data.size() > 0):
		var firstByte:PackedByteArray = Marshalls.raw_to_base64([data[0]]).to_ascii_buffer();
		var byteSize:int = firstByte.size();
		for i in range(64):
			key.append(firstByte[i % byteSize]);
	return HMACSHA256.hmac_hex(Marshalls.raw_to_base64(data).to_ascii_buffer(), key);

func _ready():
	FPSCounter.counter.visible = false;
	rng.randomize();
	if (SaveManager.saveData.vault.unlocked):
		cacheDialogue();
		vaultData.dialogue.fail = parseDialogue(Assets.getDat("vault/failureManagement", false, true));
		if (!SaveManager.saveData.vault.entered):
			SaveManager.saveData.vault.entered = true;
			SaveManager.save();
			vaultData.dialogue.data = parseDialogue(Assets.getDat("vault/firstEnter", false, true));
		else:
			var defaultDialogue:Array = parseDialogue(Assets.getDat("vault/enter", false, true));
			var maxRange:int = defaultDialogue.size() - 1;
			if (maxRange >= 0):
				vaultData.dialogue.data = [defaultDialogue[rng.randi_range(0, defaultDialogue.size() - 1)]];
		updateDialogue();
		spookyTweener = CustomFloatTweener.new(0.85, 1.0, 0.3, Tween.TRANS_BOUNCE, Tween.EASE_OUT);
		spookyTweener.inverted = true;
		add_child(spookyTweener);
		Sound.playMusic("vault", 0.5, true);
	else:
		for child in vault.get_children():
			remove_child(child);
			child.call_deferred("free");
	backTweener = CustomFloatTweener.new(0.75, 0.85, 0.25, Tween.TRANS_BOUNCE, Tween.EASE_OUT);
	backTweener.inverted = true;
	add_child(backTweener);
	InputHandler.connect("mouseDown", Callable(self, "_onPressed"));
	InputHandler.connect("mouseDrag", Callable(self, "_onDrag"));
	InputHandler.connect("mouseUp", Callable(self, "_onReleased"));
	backSize = back.texture.get_size() * back.scale;
	pass;

func _process(delta):
	if (SaveManager.saveData.vault.unlocked):
		var daScale:float = spookyTweener.current();
		spooky.scale.x = daScale;
		spooky.scale.y = daScale;
	var backScale:float = backTweener.current();
	back.scale.x = backScale;
	back.scale.y = backScale;
	pass;
