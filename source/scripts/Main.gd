extends Node2D

# var mainScene:String = "charter/ChartingState";
# var mainScene:String = "scenes/PlayState";
var mainScene:String = "charter/ChartingState";

func _ready():
	SceneTransition.switchAbsolute(mainScene);
	pass;
