extends Node2D

# var mainScene:String = "charter/ChartingState";
# var mainScene:String = "scenes/PlayState";
var mainScene:String = "scenes/PlatformerState";

func _ready():
	SceneTransition.switchAbsolute(mainScene);
	pass;
