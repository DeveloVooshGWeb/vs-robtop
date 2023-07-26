extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var aes = AESContext.new();

var iv:PackedByteArray = [
	0x4C, 0x20, 0x4E, 0x6F,
	0x20, 0x56, 0x61, 0x75,
	0x6C, 0x74, 0x20, 0x53,
	0x74, 0x75, 0x66, 0x66
];

func encrypt(key:PackedByteArray, data:PackedByteArray) -> PackedByteArray:
	aes.start(AESContext.MODE_CBC_ENCRYPT, key, iv);
	var padded:PackedByteArray = PKCS5.pad(data, 16);
	var result:PackedByteArray = aes.update(padded);
	aes.finish();
	return result;

func decrypt(key:PackedByteArray, data:PackedByteArray) -> PackedByteArray:
	aes.start(AESContext.MODE_CBC_DECRYPT, key, iv);
	var result:PackedByteArray = aes.update(data);
	aes.finish();
	result = PKCS5.unpad(result);
	return result;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
