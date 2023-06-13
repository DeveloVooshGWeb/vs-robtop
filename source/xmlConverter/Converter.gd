extends Node2D

# ASSUMPTIONS:
# - Sheet and image have the same path
# - Sheet is an Adobe Animate XML and image is a PNG
@export var load_path: String = "res://"
@export var save_path: String = "res://"
@export var optimize: bool = false
signal finished
@onready var anim_sprite = $AnimatedSprite2D
func do_it():
	
	var xml_parser = XMLParser.new()
	xml_parser.open(load_path + ".xml")
	
	var frames = anim_sprite.frames
	var texture:ImageTexture = ImageTexture.new();
	var f = FileAccess.open(load_path + ".png", FileAccess.READ);
	if (f != null && f.get_open_error() == OK):
		var byteArray:PackedByteArray = f.get_buffer(f.get_length());
		f.close();
		var img:Image = Image.new();
		img.load_png_from_buffer(byteArray);
		texture.create_from_image(img);
		# texture.flags = Texture2D.FLAG_FILTER;
		
	var cur_anim_name;
	
	# print(ResourceSaver._get_recognized_extensions(frames))
	
	var err = xml_parser.read()
	while err == OK:
		if xml_parser.get_node_type() == XMLParser.NODE_ELEMENT || xml_parser.get_node_type() == XMLParser.NODE_ELEMENT_END:
			print("--- " + xml_parser.get_node_name() + " ---")
			
			if xml_parser.get_node_name() != "TextureAtlas":
				var loaded_anim_name: String = xml_parser.get_named_attribute_value("name")
				loaded_anim_name = loaded_anim_name.left(len(loaded_anim_name) - 4)
				print("loaded name: " + loaded_anim_name)
				
				if cur_anim_name != loaded_anim_name:
					frames.add_animation_library(loaded_anim_name)
					frames.set_animation_loop(loaded_anim_name, false)
					frames.set_animation_speed(loaded_anim_name, 24)
					cur_anim_name = loaded_anim_name
				
				var new_region = Rect2(int(xml_parser.get_named_attribute_value("x")), int(xml_parser.get_named_attribute_value("y")),
									   int(xml_parser.get_named_attribute_value("width")), int(xml_parser.get_named_attribute_value("height")))
				var new_margin = Rect2()
				if xml_parser.has_attribute("frameX"):
					new_margin = Rect2(-int(xml_parser.get_named_attribute_value("frameX")), -int(xml_parser.get_named_attribute_value("frameY")),
										int(xml_parser.get_named_attribute_value("frameWidth")) - new_region.size.x, int(xml_parser.get_named_attribute_value("frameHeight")) - new_region.size.y)
				
				var num_frames = frames.get_frame_count(cur_anim_name)
				var prev_frame = frames.get_frame(cur_anim_name, num_frames - 1) if num_frames > 0 else null
				
				if optimize && prev_frame && new_region == prev_frame.region && new_margin == prev_frame.margin:
					print("optimizing " + str(num_frames))
					frames.add_frame(cur_anim_name, prev_frame)
				else:
					var new_frame = AtlasTexture.new()
					new_frame.atlas = texture
					new_frame.region = new_region
					new_frame.margin = new_margin
					# new_frame.flags = Texture.FLAG_MIPMAPS
					# new_frame.flags = Texture2D.FLAG_FILTER
					new_frame.filter_clip = true
					
					# var frame_path: String = save_path + "/" + loaded_anim_name;
					
					# var dir = Directory.new();
					# if (!dir.dir_exists(frame_path)):
					#	dir.make_dir_recursive(frame_path);
					
					# frame_path += "/" + loaded_anim + ".png";
					
					# var frameFile = File.new();
					# var fErr: bool = frameFile.open(frame_path, File.WRITE) != OK;
					# if (!fErr):
					#	frameFile.store_buffer(new_frame.get_data().get_data());
					#	frameFile.close();
				# new_frame.get_data().save_png(frame_path);
				
					frames.add_frame(cur_anim_name, new_frame)
					$AnimatedSprite2D.play(loaded_anim_name)
		await get_tree().create_timer(0.01).timeout
		err = xml_parser.read()
	
	print("done")
	
	frames.remove_animation_library("default")
	ResourceSaver.save(frames, save_path + ".res", ResourceSaver.FLAG_COMPRESS)
	
	emit_signal("finished")
func _ready():
	set_process(false)
	
	await get_tree().idle_frame
	
var bunce = false
func _input(event):
	if event.is_action_pressed("confirm"):
		if bunce == false:
			bunce = true
			save_path = $Panel/savepath.text
			load_path = $Panel/loadpath.text
			$Panel/savepath.hide()
			$Panel/loadpath.hide()
			do_it()
			await self.finished
			$AnimatedSprite2D.hide()
			$Panel/loadpath.text = ""
			$Panel/savepath.text = ""
			$Panel/loadpath.placeholder_text = ""
			$Panel/savepath.placeholder_text = "";
			get_tree().quit();
