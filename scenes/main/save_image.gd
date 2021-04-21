extends Node


# Some code here is by laame


onready var main: Control = get_parent()


func _ready() -> void:
	if OS.get_name() == "HTML5" and OS.has_feature("JavaScript"):
		define_js()


func save_file(path:String) -> void:
	var images: Array = []
	for layer in main.preview.get_children():
		for texture_rect in layer.get_children():
			var data = get_texture_data(texture_rect)
			if data:
				images.append(data)
	var result_img: Image
	for img in images:
		if result_img:
			result_img.blend_rect(img, Rect2(0, 0, img.get_width(), img.get_height()), Vector2.ZERO)
		else:
			result_img = img
	
	if path:
		result_img.save_png(path)
	else:
		var hash_str: String = str(hash(result_img))
		if OS.get_name() == "Android":
			# Saves the image in a user-accessible folder
			var save_path: String = "/sdcard/Android" + ProjectSettings.globalize_path("user://").substr(5)
			path = save_path + "character_" + hash_str + ".png"
			var dir: Directory = Directory.new()
			if not dir.dir_exists(save_path):
				dir.make_dir_recursive(save_path)
			result_img.save_png(path)
		else:
			download_image(result_img, "character_" + hash_str)
	
	main.call_deferred("save_finished", path)


func define_js() -> void:
	# Define JS script
	JavaScript.eval("""
	function download(fileName, byte) {
		var buffer = Uint8Array.from(byte);
		var blob = new Blob([buffer], { type: 'image/png'});
		var link = document.createElement('a');
		link.href = window.URL.createObjectURL(blob);
		link.download = fileName;
		link.click();
	};
	""", true)


func get_texture_data(texture:TextureRect) -> Image:
	if texture.texture:
		var i: Image = texture.texture.get_data()
		var mod: Color = texture.modulate
		if mod != Color.white:
			i.lock()
			for x in range(i.get_width()):
				for y in range(i.get_height()):
					var c: Color = i.get_pixel(x, y)
					if c.a != 0:
						var r: Color = c * mod
						i.set_pixel(x, y, r)
			i.unlock()
		return i
	else:
		return null


func download_image(image:Image, fileName:String="export") -> void:
	if OS.get_name() != "HTML5" or !OS.has_feature("JavaScript"):
		return
		
	image.clear_mipmaps()
	if image.save_png("user://export_temp.png"):
		return
	var file: File = File.new()
	if file.open("user://export_temp.png", File.READ):
		return
	
	# Read data as PoolByteArray and convert it to Array for JS
	var pngData: Array = Array(file.get_buffer(file.get_len()))
	file.close()
	var dir: Directory = Directory.new()
	dir.remove("user://export_temp.png")
	JavaScript.eval("download('%s', %s);" % [fileName, str(pngData)], true)
