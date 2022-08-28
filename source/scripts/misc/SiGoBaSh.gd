extends Node2D

onready var spr:AnimatedSprite = get_node("AnimatedSprite");
onready var tween:Tween = get_node("Tween");

var rng:RandomNumberGenerator = RandomNumberGenerator.new();
var velocity:Vector2 = Vector2.ZERO;
var accelY:float = 550;
var curFrame:int = 0;

func _ready():
	rng.randomize();
	spr.frame = curFrame;
	velocity.y = rng.randi_range(-175, -140);
	velocity.x = rng.randi_range(-10, 0);
	tween.interpolate_property(self, "modulate", Color8(255, 255, 255, 255), Color8(255, 255, 255, 0), 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN, BeatHandler.beatSecs);
	tween.start();
	visible = true;
	pass;

func _physics_process(delta):
	position += velocity * delta;
	velocity.y += accelY * delta;
	pass;

func _process(delta):
	if (modulate.a <= 0):
		call_deferred("free");
	pass;

func _fixed_process(delta):
	queue_free();
	pass;
