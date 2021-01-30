extends Node

const HEADPHONES_UP = preload("res://sprites/male/headphones_up/04_headphones_up.png")
const HEADPHONES_BASE = preload("res://sprites/male/headphones_base/00_headphones.png")
const CROSS_N = preload("res://theme/images/cross_normal.png")
const CROSS_T = preload("res://theme/images/cross_toggled.png")
const ItemScroll = preload("res://scenes_scripts/ItemScroll.tscn")
var gender_info = [
	{
		"gender": "female",
		"curr_option": 0,
		"img_size": Vector2(1011, 1145),
		"prev_img_size": Vector2(185, 210),
		"base": preload("res://sprites/female/base/base_female.png"),
		"options":
			{
				"accessories": ["flower", "choker", "glasses"],
				"expressions": ["expressions"],
				"hairs_front": ["hairs_front"],
				"costumes": ["costumes"],
				"blushes": ["blushes"],
				"hairs_behind": ["hairs_behind"]
			},
		"groups": ["flower", "choker", "glasses", "expressions", "hairs_front", "costumes", "blushes", "hairs_behind"],
		"layers": {},
		"button_groups": {},
		"sprites": {}
	},
	{
		"gender": "male",
		"curr_option": 0,
		"img_size": Vector2(1158, 1287),
		"prev_img_size": Vector2(185, 206),
		"base": preload("res://sprites/male/base/base_male.png"),
		"options":
			{
				"accessories": ["sweatdrop", "headphones_up", "glasses", "headphones_base"],
				"expressions": ["expressions"],
				"hairs_front": ["eye_cover", "hairs_front"],
				"costumes": ["costumes"],
				"hairs_behind": ["hairs_behind"]
			},
		"groups": ["sweatdrop", "headphones_up", "eye_cover", "glasses", "expressions", "hairs_front", "costumes", "headphones_base", "hairs_behind"],
		"layers": {},
		"button_groups": {},
		"sprites": {}
	}
]
var curr_gender = 0
onready var main = get_tree().get_root().get_node("Main")
onready var sprites = main.get_node("Divider/Sprites")
onready var wait = main.get_node("WaitPop")
onready var wait_label = wait.get_node("WaitLabel")
onready var item_panel = main.get_node("Divider/Options/ItemPanel")
onready var item_options = main.get_node("Divider/Options/ItemOptions")


func _ready():
	main.connect("ready", self, "_set_up_main")


func _set_up_main():
	for i in range(2):
		var children = sprites.get_child(i).get_children()
		children.remove(1) # Removes the Base TextureRect
		children.invert()
		var curr_info = gender_info[i]
		for j in range(len(children)):
			var curr_group = curr_info.groups[j]
			curr_info.layers[curr_group] = children[j]
			if curr_group == "hairs_front" and i: # Male EyeCover is same group as HairsFront
				curr_info.button_groups[curr_group] = curr_info.button_groups["eye_cover"]
			elif curr_group == "headphones_base": # Neither icon is shown at any rate
				curr_info.button_groups[curr_group] = curr_info.button_groups["headphones_up"]
			else:
				curr_info.button_groups[curr_group] = ButtonGroup.new()
	
	var gender_options = main.get_node("Divider/Options/GenderOptions")
	gender_options.add_item("Female")
	gender_options.add_item("Male")
	
	item_options.get_child(0).show()
	item_options.get_child(1).hide()
	for i in range(2):
		var child = item_options.get_child(i)
		child.connect("item_selected", self, "_on_item_selected")
		for option in gender_info[i].options:
			child.add_item(option.capitalize())
	
	var clear = main.get_node("Divider/Options/HBoxContainer/Clear")
	clear.connect("pressed", self, "_on_clear_all_pressed")
	
	var save = main.get_node("Divider/Options/HBoxContainer/Save")
	var file_dialog = main.get_node("FileDialog")
	if OS.get_name() == "HTML5" and OS.has_feature('JavaScript') or OS.get_name() == "Android":
		save.connect("pressed", self, "_save_file")
	else:
		save.connect("pressed", file_dialog, "popup_centered")
		file_dialog.connect("file_selected", self, "_save_file")
		file_dialog.current_dir = OS.get_system_dir(OS.SYSTEM_DIR_PICTURES)
		
	var credits = main.get_node("Divider/Options/HBoxContainer/Credits")
	var credits_pop = main.get_node("CreditsPop")
	credits.connect("pressed", credits_pop, "popup_centered")
	
	gender_options.connect("item_selected", self, "_on_gender_selected")
	
	sprites.get_child(0).show()
	sprites.get_child(1).hide()
	
	for i in range(2):
		for key in gender_info[i].options:
			var curr_scroll = ItemScroll.instance()
			curr_scroll.make_icons(i, key)
			item_panel.get_child(i).add_child(curr_scroll)
	
	item_panel.get_child(0).get_child(0).show()
	
	if OS.get_name() == "Android":
		var perms = OS.get_granted_permissions()
		if not "android.permission.READ_EXTERNAL_STORAGE" in perms \
		or not "android.permission.WRITE_EXTERNAL_STORAGE" in perms:
# warning-ignore:return_value_discarded
			OS.request_permissions()


func _on_gender_selected(index):
	item_panel.get_child(curr_gender).get_child(gender_info[curr_gender].curr_option).hide()
	curr_gender = index
	if index:
		sprites.get_child(0).hide()
		item_options.get_child(0).hide()
		sprites.get_child(1).show()
		item_options.get_child(1).show()
	else:
		sprites.get_child(1).hide()
		item_options.get_child(1).hide()
		sprites.get_child(0).show()
		item_options.get_child(0).show()
	item_panel.get_child(curr_gender).get_child(gender_info[curr_gender].curr_option).show()


func _on_item_selected(index):
	item_panel.get_child(curr_gender).get_child(gender_info[curr_gender].curr_option).hide()
	gender_info[curr_gender].curr_option = index
	item_panel.get_child(curr_gender).get_child(gender_info[curr_gender].curr_option).show()


func _on_icon_pressed(button_pressed, folder, sprite):
	if button_pressed:
		if folder == "headphones_up":
			gender_info[curr_gender].layers[folder].texture = HEADPHONES_UP
			gender_info[curr_gender].layers["headphones_base"].texture = HEADPHONES_BASE
		else:
			gender_info[curr_gender].layers[folder].texture = sprite
	else:
		if folder == "headphones_up":
			gender_info[curr_gender].layers[folder].texture = null
			gender_info[curr_gender].layers["headphones_base"].texture = null
		else:
			gender_info[curr_gender].layers[folder].texture = null


func _on_clear_pressed(option):
	for key in gender_info[curr_gender].options[option]:
		gender_info[curr_gender].layers[key].texture = null
		var button = gender_info[curr_gender].button_groups[key].get_pressed_button()
		if button:
			button.pressed = false


func _on_clear_all_pressed():
	for key in gender_info[curr_gender].options:
		for other_key in gender_info[curr_gender].options[key]:
			gender_info[curr_gender].layers[other_key].texture = null
			var button = gender_info[curr_gender].button_groups[other_key].get_pressed_button()
			if button:
				button.pressed = false


func _alpha_blend(color_1, color_2) -> Color:
	var result_a = color_1.a + color_2.a * (1 - color_1.a)
	var result_rgb = (color_1 * color_1.a + color_2 * color_2.a * (1 - color_1.a)) / result_a
	result_rgb.a = result_a
	return result_rgb


func _replace_pixels(bottom_img, top_img):
	top_img.lock()
	bottom_img.lock()
	for x in range(gender_info[curr_gender].img_size.x):
		for y in range(gender_info[curr_gender].img_size.y):
			var curr_pixel = top_img.get_pixel(x, y)
			if curr_pixel.a == 1:
				bottom_img.set_pixel(x, y, curr_pixel)
			elif curr_pixel.a != 0:
				var result_pixel = bottom_img.get_pixel(x, y)
				var new_color = _alpha_blend(curr_pixel, result_pixel)
				bottom_img.set_pixel(x, y, new_color)
	top_img.unlock()
	bottom_img.unlock()


func _save_file(path=null):
	wait_label.text = "Generating image..."
	wait.popup_centered()
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	
	var curr_dict = gender_info[curr_gender]
	var images = []
	for key in curr_dict.layers:
		var layer = curr_dict.layers[key]
		if layer.texture == null:
			images.append(null)
		else:
			images.append(layer.texture.get_data())
	var result_img
	if images[-1] == null:
		result_img = Image.new()
		result_img.create(curr_dict.img_size.x, curr_dict.img_size.y, false, Image.FORMAT_RGBA8)
	else:
		result_img = images[-1] # Sets the result to the "HairsBehind" image
	_replace_pixels(result_img, curr_dict.base.get_data()) # Adds "Base" image
	for i in range(len(images)-2, -1, -1): # Iterates through layers backwards
		if images[i] != null:
			_replace_pixels(result_img, images[i])
	if path:
		result_img.save_png(path)
		wait_label.text = "Image saved!"
	elif OS.get_name() == "Android":
		# Saves the image in a user-accessible folder
		var save_path = "/sdcard/Android" + ProjectSettings.globalize_path("user://").substr(5)
		var hash_str = str(hash(result_img))
		var img_path = save_path + "character_" + hash_str + ".png"
		var dir = Directory.new()
		if not dir.dir_exists(save_path):
			dir.make_dir_recursive(save_path)
		result_img.save_png(img_path)
		wait_label.text = "Image saved to " + img_path + "!"
	else:
		HTML5File.save_image(result_img, "character")
		wait_label.text = "Image downloaded!"
	yield(get_tree().create_timer(3), "timeout")
	wait.hide()
