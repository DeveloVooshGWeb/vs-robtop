extends CharacterBody2D

var sliding:bool = false;
# var vel:Vector2 = Vector2.ZERO;
var jumping:bool = false;
var start_rotating:bool = false;

@export var rotation_vel:float = 3;
@export var rotation_reset_speed:float = 6;

@export var slide_vel:float = 24;
@export var slide_stop_vel:float = 24;
@export var slide_reset_threshold:float = 16;
@export var max_move_vel:float = 512;

@export var jump_height:float = 192;
@export var jump_time_to_peak:float = 0.275;
@export var jump_time_to_descent:float = 0.25;

@onready var jump_vel:float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0;
@onready var jump_gravity:float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0;
@onready var fall_gravity:float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0;

var prev_on_floor:bool = true;

func _physics_process(delta):
	# Thanks For The Jump Mechanic!
	# Modified This: https://www.youtube.com/watch?v=IOe1aGY6hXA
	var curSign:int = sign(velocity.x);
	var absX:float = abs(velocity.x);
	if (absX >= max_move_vel):
		velocity.x = max_move_vel * curSign;
	if (velocity.x != 0 && !sliding):
		velocity.x -= slide_stop_vel * curSign;
		if (absX <= slide_reset_threshold):
			velocity.x = 0;
	var on_floor:bool = is_on_floor();
	if (jumping && on_floor):
		velocity.y = jump_vel;
		start_rotating = true; # reversed "rotating" for Camera2D
	velocity.y += get_gravity() * delta;
	# set_vel(vel)
	# set_up_direction(Vector2.UP)
	# move_and_slide()
	# vel = vel;
	# velocity = vel;
	#move_and_collide(velocity);
	move_and_slide();
	# vel = velocity;
	on_floor = is_on_floor();
	
	# Thanks For The Rotating Mechanic!
	# Modified This: https://godotengine.org/qa/90129/rotate-geometry-dash-style
	if (on_floor):
		start_rotating = true; # reversed "rotating" for Camera2D
	if (jumping && on_floor && !prev_on_floor):
		fix_rotation(0, true);
		# Fix for cube being weird when jumping (corners hitting floor and stuff)
	elif (on_floor || is_on_ceiling() || !start_rotating):
		fix_rotation(delta);
	else:
		rotation += (rotation_vel * curSign) * delta;
	
	prev_on_floor = on_floor;

func fix_rotation(delta:float, force:bool = false):
	var targetRot:float = snapped(rotation, 1.5708);
	if (force):
		rotation = targetRot;
		return;
	var rotDiff:float = targetRot - rotation;
	if (abs(rotDiff) > 0.125):
		rotation += rotation_reset_speed * sign(rotDiff) * delta;
	else:
		rotation = targetRot;

func get_gravity() -> float:
	return jump_gravity if velocity.y < 0.0 else fall_gravity;

func slide(stop:bool = true, left:bool = false):
	if (stop):
		sliding = false;
	else:
		var multiplier:float = 1;
		if (left):
			multiplier = -1;
		velocity.x += slide_vel * multiplier;
		sliding = true;
	pass;
