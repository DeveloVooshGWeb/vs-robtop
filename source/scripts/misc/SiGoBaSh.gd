extends Node2D

@onready var spr:AnimatedSprite2D = get_node("AnimatedSprite2D");
@onready var tween:Tween = get_tree().create_tween().set_parallel(true);

var rng:RandomNumberGenerator = RandomNumberGenerator.new();
var velocity:Vector2 = Vector2.ZERO;
var accelY:float = 550;
var curFrame:int = 0;

func _ready():
	rng.randomize();
	spr.frame = curFrame;
	velocity.y = rng.randi_range(-175, -140);
	velocity.x = rng.randi_range(-10, 0);
#	tween.interpolate_property(self, "modulate", Color8(255, 255, 255, 255), Color8(255, 255, 255, 0), 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN, BeatHandler.beatSecs);
	modulate = Color(1, 1, 1, 1);
	tween.tween_property(self, "modulate:a", 0, 0.2).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN).set_delay(BeatHandler.beatSecs);
#	tween.start();
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
