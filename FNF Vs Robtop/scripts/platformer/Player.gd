extends KinematicBody2D

var sliding:bool = false;
var velocity:Vector2 = Vector2.ZERO;
var jumping:bool = false;
var start_rotating:bool = false;

export var rotation_velocity:float = 3;
export var rotation_reset_speed:float = 6;

export var slide_velocity:float = 24;
export var slide_stop_velocity:float = 20;
export var slide_reset_threshold:float = 16;
export var max_move_velocity:float = 512;

export var jump_height:float = 192;
export var jump_time_to_peak:float = 0.275;
export var jump_time_to_descent:float = 0.25;

onready var jump_velocity:float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0;
onready var jump_gravity:float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0;
onready var fall_gravity:float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0;

func _physics_process(delta):
	# Thanks For The Jump Mechanic!
	# Modified This: https://www.youtube.com/watch?v=IOe1aGY6hXA
	var curSign:int = sign(velocity.x);
	var absX:float = abs(velocity.x);
	if (absX >= max_move_velocity):
		velocity.x = max_move_velocity * curSign;
	if (velocity.x != 0 && !sliding):
		velocity.x -= slide_stop_velocity * curSign;
		if (absX <= slide_reset_threshold):
			velocity.x = 0;
	var on_floor:bool = is_on_floor();
	if (jumping && on_floor):
		velocity.y = jump_velocity;
		start_rotating = true;
	velocity.y += get_gravity() * delta;
	velocity = move_and_slide(velocity, Vector2.UP);
	on_floor = is_on_floor();
	
	# Thanks For The Rotating Mechanic!
	# Modified This: https://godotengine.org/qa/90129/rotate-geometry-dash-style
	if (on_floor):
		start_rotating = false;
	if (on_floor || !start_rotating):
		fix_rotation(delta);
	else:
		rotation += (rotation_velocity * curSign) * delta;

func fix_rotation(delta):
	var targetRot:float = stepify(rotation, 1.5708);
	var rotDiff:float = targetRot - rotation;
	if (abs(rotDiff) > 0.125):
		rotation += rotation_reset_speed * sign(rotDiff) * delta;
	else:
		rotation = targetRot;
#	var rot:float = 0.0 + rotation;
#	if (rot > targetRot):
#		rot -= targetRot;
#	if (abs(rot) < targetRot):
#		rotation += (rotation_velocity * 2 * sign(rotation - 180)) * delta;

func get_gravity() -> float:
	return jump_gravity if velocity.y < 0.0 else fall_gravity;

func slide(stop:bool = true, left:bool = false):
	if (stop):
		sliding = false;
	else:
		var multiplier:float = 1;
		if (left):
			multiplier = -1;
		velocity.x += slide_velocity * multiplier;
		sliding = true;
	pass;
