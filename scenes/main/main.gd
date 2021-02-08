extends Control


const HEADPHONES_UP: StreamTexture = preload("res://sprites/male/headphones_up/00_headphones_up/00_headphones_up.png")
const HEADPHONES_BASE: StreamTexture = preload("res://sprites/male/headphones_base/00_headphones_base/00_headphones_base.png")
const ItemScroll: PackedScene = preload("res://scenes/items/item_scroll.tscn")
const NUM_GENDERS: int = 2
const COLOR_ARR: Array = ["skin", "eye", "hair"]
var gender_info: Array = [
	{
		"gender": "female",
		"curr_option": 0,
		"img_size": Vector2(1011, 1145),
		"options":
			{
				"accessories": ["flower", "choker", "glasses"],
				"expressions": ["expressions"],
				"hairs_front": ["hairs_front"],
				"costumes": ["costumes"],
				"blushes": ["blushes"],
				"hairs_behind": ["hairs_behind"],
			},
		"groups": ["flower", "choker", "glasses", "expressions", "hairs_front", "costumes", "blushes", "hairs_behind"],
		"layers": {},
		"button_groups": {},
		"colors": {
			"skin": Color.white,
			"eye": Color.white,
			"hair": Color.white,
		},
	},
	{
		"gender": "male",
		"curr_option": 0,
		"img_size": Vector2(1158, 1287),
		"options":
			{
				"accessories": ["sweatdrop", "headphones_up", "glasses", "headphones_base"],
				"expressions": ["expressions"],
				"hairs_front": ["eye_cover", "hairs_front"],
				"costumes": ["costumes"],
				"hairs_behind": ["hairs_behind"],
			},
		"groups": ["sweatdrop", "headphones_up", "eye_cover", "glasses", "expressions", "hairs_front", "costumes", "headphones_base", "hairs_behind"],
		"layers": {},
		"button_groups": {},
		"colors": {
			"skin": Color.white,
			"eye": Color.white,
			"hair": Color.white,
		},
	},
]
var cur_gender: int = 0
var cur_color: int = 0
var thread: Thread
onready var save_image: Node = $SaveImage
onready var sprites: Control = $HBox/Sprites
onready var wait_pop: PopupPanel = $WaitPop
onready var wait_label: Label = $WaitPop/WaitLabel
onready var item_panel: PanelContainer = $HBox/MarCon/Options/ItemPanel
onready var item_options: MarginContainer = $HBox/MarCon/Options/HBox/Dropdowns/ItemOptions
onready var color_box: HBoxContainer = $HBox/MarCon/Options/HBox/ColorPanel/ColorBox
onready var color_pop: PopupPanel = $ColorPop


func _ready() -> void:
	for i in range(NUM_GENDERS):
		var children: Array = sprites.get_child(i).get_children()
		children.remove(1) # Removes the Base TextureRect
		children.invert()
		var curr_info: Dictionary = gender_info[i]
		for j in range(len(children)):
			var curr_group: String = curr_info.groups[j]
			curr_info.layers[curr_group] = children[j]
			if curr_group == "hairs_front" and i: # Male EyeCover is same group as HairsFront
				curr_info.button_groups[curr_group] = curr_info.button_groups["eye_cover"]
			elif curr_group == "headphones_base": # Neither icon is shown at any rate
				curr_info.button_groups[curr_group] = curr_info.button_groups["headphones_up"]
			else:
				curr_info.button_groups[curr_group] = ButtonGroup.new()
	
	var gender_options: OptionButton = $HBox/MarCon/Options/HBox/Dropdowns/GenderOptions
	gender_options.add_item("Female")
	gender_options.add_item("Male")
	
	item_options.get_child(0).show()
	item_options.get_child(1).hide()
	for i in range(NUM_GENDERS):
		var child: OptionButton = item_options.get_child(i)
		child.connect("item_selected", self, "_on_item_selected")
		for option in gender_info[i].options:
			child.add_item(option.capitalize())
	
	var save: Button = $HBox/MarCon/Options/Buttons/Save
	var file_dialog: FileDialog = $FileDialog
	if OS.get_name() == "HTML5" and OS.has_feature("JavaScript") or OS.get_name() == "Android":
		save.connect("pressed", self, "_save_file")
	else:
		save.connect("pressed", file_dialog, "popup_centered")
		file_dialog.connect("file_selected", self, "_save_file")
		file_dialog.current_dir = OS.get_system_dir(OS.SYSTEM_DIR_PICTURES)
	
	var credits: Button = $HBox/MarCon/Options/Buttons/Credits
	var credits_pop: PopupPanel = $CreditsPop
	credits.connect("pressed", credits_pop, "popup_centered")
	credits_pop.get_node("HBox/UseInfo").connect("meta_clicked", self, "_on_meta_clicked")
	credits_pop.get_node("HBox/Credits").connect("meta_clicked", self, "_on_meta_clicked")
	
	sprites.get_child(0).show()
	sprites.get_child(1).hide()
	
	for i in range(NUM_GENDERS):
		for key in gender_info[i].options:
			var curr_scroll: ScrollContainer = ItemScroll.instance()
			item_panel.get_child(i).add_child(curr_scroll)
			curr_scroll.make_icons(i, key)
	
	item_panel.get_child(0).get_child(0).show()
	
	if OS.get_name() == "Android":
		var perms: PoolStringArray = OS.get_granted_permissions()
		if not "android.permission.READ_EXTERNAL_STORAGE" in perms \
		or not "android.permission.WRITE_EXTERNAL_STORAGE" in perms:
			OS.request_permissions()


func save_finished(path:String) -> void:
	if thread:
		thread.wait_to_finish()
	if OS.get_name() == "Android":
		wait_label.text = "Image saved to " + path + "!"
	elif path:
		wait_label.text = "Image saved!"
	else:
		wait_label.text = "Image downloaded!"
	yield(get_tree().create_timer(2), "timeout")
	wait_pop.hide()


func _on_gender_selected(index:int) -> void:
	item_panel.get_child(cur_gender).get_child(gender_info[cur_gender].curr_option).hide()
	cur_gender = index
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
	item_panel.get_child(cur_gender).get_child(gender_info[cur_gender].curr_option).show()
	for i in range(color_box.get_child_count()):
		color_box.get_child(i).get_child(1).get_child(0).color = gender_info[cur_gender].colors[COLOR_ARR[i]]


func _on_item_selected(index:int) -> void:
	item_panel.get_child(cur_gender).get_child(gender_info[cur_gender].curr_option).hide()
	gender_info[cur_gender].curr_option = index
	item_panel.get_child(cur_gender).get_child(gender_info[cur_gender].curr_option).show()


func _on_color_gui_input(event:InputEvent, i:int) -> void:
	if event is InputEventMouseButton and not event.pressed and event.button_index == BUTTON_LEFT:
		cur_color = i
		color_pop.get_child(0).color = gender_info[cur_gender].colors[COLOR_ARR[cur_color]]
		color_pop.popup_centered()
	

func _on_color_changed(color:Color) -> void:
	color_box.get_child(cur_color).get_child(1).get_child(0).color = color
	gender_info[cur_gender].colors[COLOR_ARR[cur_color]] = color
	for node in get_tree().get_nodes_in_group(COLOR_ARR[cur_color] + "_" + gender_info[cur_gender].gender):
		node.self_modulate = color


func _on_icon_pressed(button_pressed:bool, folder:String, textures:Array) -> void:
	var cur_layer: TextureRect = gender_info[cur_gender].layers[folder]
	if button_pressed:
		if folder == "headphones_up":
			cur_layer.texture = HEADPHONES_UP
			gender_info[cur_gender].layers["headphones_base"].texture = HEADPHONES_BASE
		else:
			cur_layer.texture = textures[0]
			for i in range(1, textures.size()):
				if textures[i]:
					cur_layer.get_child(i-1).texture = textures[i]
	else:
		cur_layer.texture = null
		for child in cur_layer.get_children():
			child.texture = null
		if folder == "headphones_up":
			gender_info[cur_gender].layers["headphones_base"].texture = null


func _on_clear_pressed(option:String) -> void:
	for key in gender_info[cur_gender].options[option]:
		gender_info[cur_gender].layers[key].texture = null
		var button: TextureButton = gender_info[cur_gender].button_groups[key].get_pressed_button()
		if button:
			button.pressed = false


func _on_clear_all_pressed() -> void:
	for key in gender_info[cur_gender].options:
		for other_key in gender_info[cur_gender].options[key]:
			gender_info[cur_gender].layers[other_key].texture = null
			var button: TextureButton = gender_info[cur_gender].button_groups[other_key].get_pressed_button()
			if button:
				button.pressed = false


func _save_file(path:String="") -> void:
	wait_label.text = "Generating image..."
	wait_pop.popup_centered()
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	
	var arr: Array = [path, sprites.get_child(cur_gender)]
	if OS.get_name() == "HTML5":
		save_image.save_file(arr)
	else:
		thread = Thread.new()
		thread.start(save_image, "save_file", arr)


# In case the RichTextLabel url BBCode doesn't work
func _on_meta_clicked(meta:String) -> void:
	OS.shell_open(meta)
