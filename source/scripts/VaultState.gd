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

func shuffleDialogue():
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
					EaseHandler.playEase("spooky");
				else:
					EaseHandler.playEase("spooky", true);
		if (Utils.collide(pos, Vector2.ZERO, back.position, backSize)):
			EaseHandler.playEase("back");
		else:
			EaseHandler.playEase("back", true);

func _onReleased(index:int, pos:Vector2):
	if (index == 1):
		if (SaveManager.saveData.vault.unlocked):
			EaseHandler.playEase("spooky", true);
			if (spookySelected):
				processVault();
				spookySelected = false;
		EaseHandler.playEase("back", true);
		if (backSelected):
			SceneTransition.switch("MainMenuState", true);
			backSelected = false;

func processVault():
	input.text = input.text.to_lower();
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
					dialogue.text = "lol ok";
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
	FPSCounter.get_node("FPSCanvas/FPS").visible = false;
	EaseHandler.clear();
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
		EaseHandler.setEase("spooky", 0.85, 1.0, 0.3, "Bounce", "EaseOut");
		Sound.playMusic("vault", 0.5, true);
	else:
		for child in vault.get_children():
			remove_child(child);
			child.call_deferred("free");
	EaseHandler.setEase("back", 0.75, 0.85, 0.25, "Bounce", "EaseOut");
	InputHandler.connect("mouseDown", Callable(self, "_onPressed"));
	InputHandler.connect("mouseDrag", Callable(self, "_onDrag"));
	InputHandler.connect("mouseUp", Callable(self, "_onReleased"));
	backSize = back.texture.get_size() * back.scale;
	pass;

func _process(delta):
	if (SaveManager.saveData.vault.unlocked):
		var daScale:float = EaseHandler.getEase("spooky");
		spooky.scale.x = daScale;
		spooky.scale.y = daScale;
	var backScale:float = EaseHandler.getEase("back");
	back.scale.x = backScale;
	back.scale.y = backScale;
	pass;
