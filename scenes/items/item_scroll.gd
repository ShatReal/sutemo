extends ScrollContainer


const Item: PackedScene = preload("res://scenes/items/item.tscn")
const PATH_START: String = "res://sprites/"
const HP_PATH: String = "res://sprites/other/"
const HP_FILE_PATH: String = "headphones_icon.png" # This one has to be set up manually

var scrolling := false

onready var main: Control = $"/root/Main"
onready var grid: GridContainer = $ItemGrid
onready var tween:Tween = $Tween


func _gui_input(event):
	if event is InputEventScreenDrag:
		scrolling = true
		tween.interpolate_property(
			self,
			"scroll_vertical",
			scroll_vertical,
			# Reverse scroll
			scroll_vertical-event.speed.y,
			0.5,
			Tween.TRANS_SINE)
		tween.start()


func make_icons(gender:int, option:String) -> void:
	hide()
	# Adds remove selection button
	var curr_item: VBoxContainer = Item.instance()
	grid.add_child(curr_item)
	curr_item.init_clear(option)
	
	var folders: Array = main.gender_info[gender].options[option]
	var dir: Directory = Directory.new()
	dir.open(PATH_START)
	
	for folder in folders:
		if folder == "headphones_up":
			curr_item = Item.instance()
			grid.add_child(curr_item)
			curr_item.init(gender, option, HP_PATH, [HP_FILE_PATH], folder)
			continue
		elif folder == "headphones_base":
			continue
		
		var cur_path: String = PATH_START + main.gender_info[gender].gender + "/" + folder + "/"
		dir.change_dir(cur_path)
		dir.list_dir_begin()
		var dir_queue: Array = []
		var dir_name: String = dir.get_next()
		while dir_name != "":
			if not dir_name.begins_with("."):
				dir_queue.append(dir_name)
			dir_name = dir.get_next()
		for inner_dir in dir_queue:
			var inner_dir_path = cur_path + inner_dir + "/"
			dir.change_dir(inner_dir_path)
			dir.list_dir_begin()
			var files: Array = []
			var file_name = dir.get_next()
			while file_name != "":
				if file_name.ends_with(".import"):
					files.append(file_name.replace(".import", ""))
				file_name = dir.get_next()
			curr_item = Item.instance()
			grid.add_child(curr_item)
			curr_item.init(gender, option, inner_dir_path, files, folder)


func on_tween_all_completed():
	scrolling = false
