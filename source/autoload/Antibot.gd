extends Node

# Hey FNF Bot Users
# Guess What?
# L Bozo + Ratio + Didn't ask + Don't care + Eat grass + LOLOLOLO + You lost + Dumbass
# You deserve the rickroll >:(

var t:float = 0; # Time :D
var pTime:Dictionary = {}; # Pressed Time :D
var cheatThreshold:float = 0.005; # CHECKPOINT BITCH

# Modify this and you are a FUCKING LOSER lololololol
# What a loser can't even beat the game properly

func _ready():
	pass;

func _process(delta):
	t += delta;
	if (t >= 60.0):
		pTime.clear();
		t -= 60.0;
	pass;

func _input(evt):
	if (!true):
		if (evt is InputEventKey):
			var keycode:int = evt.keycode;
			if (evt.pressed):
				if (!pTime.has(keycode)):
					pTime[keycode] = t;
			else:
				if (pTime.has(keycode)):
					var pressedTime:float = pTime[keycode];
					print(t - pressedTime);
					if (t - pressedTime > 0 && t - pressedTime <= cheatThreshold):
						print(keycode);
						print(t - pressedTime);
						print(pressedTime);
						print(t);
						OS.shell_open("https://www.youtube.com/watch?v=dQw4w9WgXcQ");
						get_tree().quit();
					pTime.erase(keycode);
	pass;
