extends ScrollContainer

const Item = preload("res://scenes_scripts/Item.tscn")
const PATH_START = "res://sprites/"
const HEADPHONES_ICON = "res://sprites/male/headphones_up/headphones_icon.png" # This one has to be set up manually


func make_icons(gender, option):
	hide()
	var grid = $ItemGrid
	var curr_item = Item.instance()
	curr_item.init(gender, option, null, null)
	grid.add_child(curr_item) # Adds remove selection button
	var folders = Global.gender_info[gender].options[option]
	var dir = Directory.new()
	if dir.open(PATH_START) == OK:
		for folder in folders:
			if folder == "headphones_up":
				curr_item = Item.instance()
				curr_item.init(gender, option, HEADPHONES_ICON, folder)
				grid.add_child(curr_item)
				continue
			elif folder == "headphones_base":
				continue
			var curr_path = PATH_START + Global.gender_info[gender].gender + "/" + folder + "/"
			dir.change_dir(curr_path)
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				if not dir.current_is_dir() and file_name.ends_with(".import"):
					var full_path = curr_path + file_name.replace(".import", "")
					curr_item = Item.instance()
					curr_item.init(gender, option, full_path, folder)
					grid.add_child(curr_item)
				file_name = dir.get_next()
	else:
		print("Path failed to open!")
