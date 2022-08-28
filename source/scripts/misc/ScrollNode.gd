extends Node2D

var scrollFactor:Vector2 = Vector2.ONE;

var nodePosition:Vector2 = Vector2.ZERO;
var basePosition:Vector2 = Vector2.ZERO;
var curPosition:Vector2 = Vector2.ZERO;

func _ready():
	nodePosition = position;
	pass;

func _process(delta):
	var posDiff:Vector2 = curPosition - basePosition;
	position = nodePosition + ((posDiff * scrollFactor) - posDiff);
	pass;
