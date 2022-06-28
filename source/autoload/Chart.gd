extends Node

func stringToByteArray(string:String) -> PoolByteArray:
	var bytes:PoolByteArray = [string.length()];
	bytes.append_array(string.to_ascii());
	return bytes;

func stringToInt16Array(string:String) -> PoolByteArray:
	var bytes:PoolByteArray = [];
	var strLen:int = string.length();
	bytes.append(strLen >> 8);
	bytes.append(strLen & 255);
	bytes.append_array(string.to_ascii());
	return bytes;

func translateC2P(data:Array):
	var stepCount:float = (data[0] * 16) + data[1];
	return stepCount * BeatHandler.stepSecs;

func translateP2C(secs:float):
	var data:Array = [0, 0.0];
	data[1] = secs / BeatHandler.stepSecs;
	data[0] = int(data[1] / 16);
	data[1] -= data[0] * 16;
	return data;

func noteRowSort(a:Dictionary, b:Dictionary) -> bool:
	return a.row < b.row;

func noteDictToNoteArr(noteDict:Dictionary) -> Array:
	var noteArr:Array = [];
	for key in noteDict.keys():
		noteArr.append(noteDict[key]);
	noteArr.sort_custom(Chart, "noteRowSort");
	return noteArr;

func noteArrToNoteDict(noteArr:Array) -> Dictionary:
	var noteDict:Dictionary = {};
	for i in range(noteArr.size()):
		noteDict[noteArr[i].hash()] = noteArr[i];
	return noteDict;

func conv(data:Dictionary) -> PoolByteArray:
	var chartData:PoolByteArray = [];
	var speed:int = int(data.speed * 100);
	chartData.append_array([data.bpm >> 8, data.bpm & 255, speed >> 8, speed & 255]);
	chartData.append_array(stringToByteArray(data.song));
	var sections:Array = data.sections;
	var sectionList:int = sections.size();
	chartData.append_array([sectionList >> 8, sectionList & 255]);
	for i in range(sectionList):
		var section:Dictionary = sections[i];
		var boolByte:int = 0;
		if (section.mustHitSection):
			boolByte = 1;
		chartData.append(boolByte);
		var notes:Array = section.notes;
		var notesSize:int = notes.size();
		chartData.append_array([notesSize >> 8, notesSize & 255]);
		for j in range(notesSize):
			var note:Dictionary = notes[j];
			var altBool:int = 0;
			if (note.alt):
				altBool = 1;
			chartData.append(altBool);
			var col:int = note.col * 16;
			var row:int = note.row * 2;
			chartData.append_array([col, row]);
			chartData.append_array([note.noteType, note.noteId]);
			var noteOffset:Array = [int(note.noteOffset.x * 100), int(note.noteOffset.y * 100)];
			chartData.append(noteOffset[0] >> 8);
			chartData.append(noteOffset[0] & 255);
			chartData.append(noteOffset[1] >> 8);
			chartData.append(noteOffset[1] & 255);
			var noteLength:int = int(note.noteLength * 100);
			chartData.append_array([noteLength >> 8, noteLength & 255]);
			chartData.append_array(stringToInt16Array(note.evt));
	return chartData;

func add(num:Dictionary) -> int:
	num.int += 1;
	return num.int;

func addN(num:Dictionary, add:int) -> int:
	num.int += add - 1;
	return num.int;

func parse(chartData:PoolByteArray) -> Dictionary:
	var data:Dictionary = {
		"bpm": 130,
		"speed": 1.0,
		"song": "",
		"sections": []
	};
	if (chartData.size() > 0):
		var ind:Dictionary = {
			"int": -1
		}
		data.bpm = chartData[add(ind)] << 8 | chartData[add(ind)];
		data.speed = float(chartData[add(ind)] << 8 | chartData[add(ind)]) / 100.0;
		var songLen:int = chartData[add(ind)];
		data.song = chartData.subarray(add(ind), addN(ind, songLen)).get_string_from_ascii();
		var sectionLen:int = chartData[add(ind)] << 8 | chartData[add(ind)];
		for i in range(sectionLen):
			var section:Dictionary = {
				"mustHitSection": chartData[add(ind)] == 1,
				"notes": []
			};
			var noteCount:int = chartData[add(ind)] << 8 | chartData[add(ind)];
			for j in range(noteCount):
				var note:Dictionary = Data.defaultProperties.duplicate(true);
				note.alt = chartData[add(ind)] != 0;
				note.isStrum = false;
				note.col = int(chartData[add(ind)] / 16);
				note.row = int(chartData[add(ind)] / 2);
				note.noteType = chartData[add(ind)];
				note.noteId = chartData[add(ind)];
				note.noteOffset = Vector2(chartData[add(ind)] << 8 | chartData[add(ind)], chartData[add(ind)] << 8 | chartData[add(ind)]);
				note.noteLength = float(chartData[add(ind)] << 8 | chartData[add(ind)]) / 100.0;
				var evtLen:int = chartData[add(ind)] << 8 | chartData[add(ind)];
				note.evt = chartData.subarray(add(ind), addN(ind, evtLen)).get_string_from_ascii();
				section.notes.append(note);
			data.sections.append(section);
	return data;

func _ready():
	pass;
