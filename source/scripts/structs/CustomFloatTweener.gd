extends Node
class_name CustomFloatTweener

var _err_message:String = "Error fetching data from CustomFloatTweener without initialization.";
var _run:bool = false;

var _tween_done:bool;
var _tween:Tween;
var _duration:float;
var _current:float;
var _base:float;
var _target:float;
var _ttype:int;
var _etype:int;
var _pmode:int;

func _notification(what):
	match (what):
		NOTIFICATION_PREDELETE:
			if (_tween):
				_tween.finished.disconnect(Callable(self, "_tween_cb"));
				_tween.kill();

func _tween_cb():
	_tween_done = true;

func _refresh_tween() -> bool:
	if (_tween_done):
		_tween_done = false;
		if (_tween):
			_tween.finished.disconnect(Callable(self, "_tween_cb"));
			_tween.kill();
		_tween = get_tree().create_tween().set_parallel(true);
		_tween.finished.connect(Callable(self, "_tween_cb"));
		_tween.set_pause_mode(_pmode);
		return true;
	if (_tween):
		_tween.set_pause_mode(_pmode);
	return false;

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS;

func _init(a:float = 0, b:float = 1, c:float = 1, transType:int = 0, easeType:int = 0, pauseMode:int = 0) -> void:
	_duration = c;
	_base = a;
	_current += _base;
	_target = b;
	_ttype = transType;
	_etype = easeType;
	_pmode = pauseMode;
	_run = true;
	pass;

func current() -> float:
	if (!_run):
		print_verbose(_err_message);
		return 0;
	return _current;

func duration() -> float:
	if (!_run):
		print_verbose(_err_message);
		return 0;
	return _duration;

func base() -> float:
	if (!_run):
		print_verbose(_err_message);
		return 0;
	return _base;

func target() -> float:
	if (!_run):
		print_verbose(_err_message);
		return 0;
	return _target;

var inverted:bool = false;

func play(seek:float = 0) -> void:
	if (!_run):
		print_verbose(_err_message);
		return;
	if (!inverted):
		return;
	inverted = false;
	_tween_cb();
	_refresh_tween();
	_tween.tween_property(self, "_current", _target, _duration).from(_base).set_trans(_ttype).set_ease(_etype);
	_tween.custom_step(seek);

func play_invert(seek:float = 0) -> void:
	if (!_run):
		print_verbose(_err_message);
		return;
	if (inverted):
		return;
	inverted = true;
	_tween_cb();
	_refresh_tween();
	_tween.tween_property(self, "_current", _base, _duration).from(_target).set_trans(_ttype).set_ease(_etype);
	_tween.custom_step(seek);

func time() -> float:
	if (!_run):
		print_verbose(_err_message);
		return 0;
	if (_refresh_tween() || !_tween):
		return _duration;
	return _tween.get_total_elapsed_time();
