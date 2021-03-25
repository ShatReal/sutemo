extends Control


const NUM_GENDERS := 2
const COLOR_ARR := ["skin", "eye", "hair"]
const IMG_SIZE := Vector2(1_000, 1_200)
const OPTION_GROUPS := {
	"back_hair": ["back_hair"],
	"blushes": ["blushes"],
	"neck": ["neck"],
	"outfits": ["outfits"],
	"front_hair": ["front_hair", "eye_cover_hair"],
	"eyes": ["eyes"],
	"mouths": ["mouths"],
	"glasses": ["glasses"],
	"accessories": ["headphones_base", "headphones_up", "accessories"],
}

var cur_gender: int = 0
var cur_option := 0
var cur_color: int = 0
var layers := {}
var button_groups := {}
var cur_colors := {
	"skin": Color("#fff9df"),
	"eye": Color("#ff8fcd"),
	"hair": Color("#eae4e6"),
}
var thread: Thread

onready var save_image := $SaveImage
onready var preview := $HBox/Preview
onready var wait_pop: PopupPanel = $WaitPop
onready var wait_label: Label = $WaitPop/WaitLabel
onready var item_panel: PanelContainer = $HBox/MarCon/Options/ItemPanel
onready var item_options := $HBox/MarCon/Options/HBox/Dropdowns/ItemOptions
onready var color_box: HBoxContainer = $HBox/MarCon/Options/HBox/ColorPanel/ColorBox
onready var color_pop: PopupPanel = $ColorPop


func _ready() -> void:
	determine_save_method()
	set_gender_option_button()
	set_item_option_button()
	modulate_sprites()
	connect_credits()
	make_items()
	request_perms_android()


func determine_save_method():
	var save := $HBox/MarCon/Options/Buttons/Save
	if OS.get_name() == "HTML5" and OS.has_feature("JavaScript") or OS.get_name() == "Android":
		save.connect("pressed", self, "save_file")
	else:
		var file_dialog := $FileDialog
		save.connect("pressed", file_dialog, "popup_centered")
		file_dialog.connect("file_selected", self, "save_file")
		file_dialog.current_dir = OS.get_system_dir(OS.SYSTEM_DIR_PICTURES)
		

func set_gender_option_button():
	var g := $HBox/MarCon/Options/HBox/Dropdowns/GenderOptions
	g.add_item("Female")
	g.add_item("Male")
	

func set_item_option_button():
	for option in OPTION_GROUPS:
		item_options.add_item(option.capitalize())
	

func modulate_sprites():
	for color_key in cur_colors:
		color_box.get_node("%s/PanelContainer/ColorRect" % color_key.capitalize()).color = cur_colors[color_key]
		for node in get_tree().get_nodes_in_group(color_key):
			node.self_modulate = cur_colors[color_key]


func connect_credits():
	var credits := $HBox/MarCon/Options/Buttons/Credits
	var credits_pop := $CreditsPop
	credits.connect("pressed", credits_pop, "popup_centered")


func make_items():
	for i in NUM_GENDERS:
		for option in OPTION_GROUPS:
			item_panel.get_child(i).make_icons(i, option)
	

func request_perms_android():
	if OS.get_name() == "Android":
		var perms := OS.get_granted_permissions()
		if not "android.permission.READ_EXTERNAL_STORAGE" in perms \
		or not "android.permission.WRITE_EXTERNAL_STORAGE" in perms:
			OS.request_permissions()


func save_finished(path:String):
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


func on_gender_selected(index:int):
	item_panel.get_child(cur_gender).get_child(cur_option).hide()
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


func on_item_option_selected(index:int) -> void:
	item_panel.get_child(cur_gender).get_child(gender_info[cur_gender].curr_option).hide()
	gender_info[cur_gender].curr_option = index
	item_panel.get_child(cur_gender).get_child(gender_info[cur_gender].curr_option).show()


func _on_color_gui_input(event:InputEvent, i:int) -> void:
	if event is InputEventMouseButton and not event.pressed and event.button_index == BUTTON_LEFT:
		cur_color = i
		color_pop.get_child(0).color = gender_info[cur_gender].colors[COLOR_ARR[cur_color]]
		color_pop.popup_centered()
	

func on_color_picker_color_changed(color:Color) -> void:
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
func on_meta_clicked(meta:String) -> void:
	OS.shell_open(meta)
