extends Node

func collide(p1:Vector2, s1:Vector2, p2:Vector2, s2:Vector2) -> bool:
	var r1:Vector2 = Vector2(s1.x / 2, s1.y / 2);
	var r2:Vector2 = Vector2(s2.x / 2, s2.y / 2);
	return p1.x + r1.x >= p2.x - r2.x && p1.x - r1.x <= p2.x + r2.x && p1.y + r1.y >= p2.y - r2.y && p1.y - r1.y <= p2.y + r2.y;

func snake_case(string:String) -> String:
	return string.strip_edges().to_lower().replace(" ", "_");

func _ready():
	pass;
