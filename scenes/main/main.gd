extends Control


enum Genders {FEMALE, MALE}
enum Options {ACCESSORIES, GLASSES, MOUTHS, EYES, FRONT_HAIR, OUTFITS, NECK, BLUSHES, BACK_HAIR}
enum Colors {SKIN, EYE, HAIR}

const IMG_SIZE := Vector2(1_000, 1_200)
const OPTION_GROUPS := [
	"back_hair",
	"body",
	"blushes",
	"neck",
	"outfits",
	"headphones_base",
	"front_hair",
	"eyes",
	"mouths",
	"glasses",
	"eye_cover_hair",
	"headphones_up",
	"accessories",
]
const COLOR_OPTIONS := ["skin", "eye", "hair"]
const WAIT_POP_TIME := 2
const ItemClass := preload("res://scenes/main/item.tscn")

var cur_gender:int = Genders.FEMALE
var cur_option:int = Options.ACCESSORIES
var cur_colors := [Color("#fff9df"), Color("#ff8fcd"), Color("#eae4e6")]
var color_rects := []
var cur_color:int = Colors.SKIN
var images := []
var cur_items := []
var thread: Thread
var save_info := {
	"gender": Genders.FEMALE,
	"layers": [],
}


onready var save_image := $SaveImage
onready var preview := $HBox/Preview
onready var wait_pop: PopupPanel = $WaitPop
onready var wait_label: Label = $WaitPop/WaitLabel
onready var item_grid := $HBox/MarCon/Options/PanelContainer/ItemScroll/ItemGrid
onready var item_options := $HBox/MarCon/Options/HBox/Dropdowns/ItemOptions
onready var color_box: HBoxContainer = $HBox/MarCon/Options/HBox/ColorPanel/ColorBox
onready var color_pop := $ColorPop
onready var color_picker := $ColorPop/ColorPicker


func _ready() -> void:
	determine_save_method()
	set_item_option_button()
	connect_credits()
	connect_color_picker()
	init_cur_items()
	load_items()
	make_items()
	request_perms_android()
	yield(get_tree(), "idle_frame")
	_set_grid_sep()


func determine_save_method():
	var save := $HBox/MarCon/Options/Buttons/Save
	if OS.get_name() == "HTML5" and OS.has_feature("JavaScript") or OS.get_name() == "Android":
		save.connect("pressed", self, "save_file")
	else:
		var file_dialog := $FileDialog
		save.connect("pressed", file_dialog, "popup_centered")
		file_dialog.connect("file_selected", self, "save_file")
		file_dialog.current_dir = OS.get_system_dir(OS.SYSTEM_DIR_PICTURES)


func set_item_option_button():
	for option in OPTION_GROUPS:
		item_options.add_item(option.capitalize())
	

func connect_credits():
	$HBox/MarCon/Options/Buttons/Credits.connect("pressed", $Credits, "popup_centered")


func connect_color_picker():
	color_picker.connect("color_changed", self, "on_color_picker_color_changed")


func init_cur_items():
	cur_items.resize(OPTION_GROUPS.size())
	cur_items[1] = 0


func load_items():
	var base_path = "res://sprites/"
	var dir = Directory.new()
	dir.open(base_path)
	var genders = []
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not file_name.begins_with("."):
			genders.append(file_name)
		file_name = dir.get_next()
	var i = 0
	for gender in genders:
		images.append([])
		var gender_path = base_path + gender + "/"
		dir.change_dir(gender_path)
		dir.list_dir_begin()
		var layers = []
		file_name = dir.get_next()
		while file_name != "":
			if not file_name.begins_with("."):
				layers.append(file_name)
			file_name = dir.get_next()
		var j = 0
		for layer in layers:
			images[i].append([])
			var layer_path = gender_path + layer + "/"
			dir.change_dir(layer_path)
			dir.list_dir_begin()
			var items = []
			file_name = dir.get_next()
			while file_name != "":
				if not file_name.begins_with("."):
					items.append(file_name)
				file_name = dir.get_next()
			var k = 0
			for item in items:
				images[i][j].append([])
				var item_path = layer_path + item + "/"
				dir.change_dir(item_path)
				dir.list_dir_begin()
				var item_layers = []
				file_name = dir.get_next()
				while file_name != "":
					if not file_name.begins_with(".") and file_name.ends_with(".import"):
						item_layers.append(file_name.replace(".import", ""))
					file_name = dir.get_next()
				for item_layer in item_layers:
					images[i][j][k].append(load(item_path + item_layer))
				k += 1
			j += 1
		i += 1
	dir.list_dir_end()


func make_items():
	for child in item_grid.get_children():
		child.queue_free()
	var option_arr = images[cur_gender][cur_option]
	for i in option_arr.size():
		var item = option_arr[i]
		var item_instance := ItemClass.instance()
		item_instance.item_indices = PoolIntArray([cur_gender, cur_option, i])
		var item_name = item[0].resource_path.split("/")[-2].substr(3).capitalize()
		item_name = item_name.replace(" - ", "-")
		item_instance.get_node("Label").text = item_name
		for j in item.size():
			var item_layer = item[j]
			var node_name = item_layer.resource_path.get_file().replace(".png", "").capitalize()
			var texture_rect = item_instance.get_node("Control/" + node_name)
			item_instance.layer_indices[texture_rect.get_index()] = j
			texture_rect.texture = item_layer
			if "hair" in OPTION_GROUPS[cur_option] and node_name == "Base":
				texture_rect.add_to_group("hair")
			elif OPTION_GROUPS[cur_option] == "eyes" and node_name == "Base":
				texture_rect.add_to_group("eye")
		item_instance.add_to_group("item")
		item_instance.get_node("Control/Static").connect("gui_input", self, "on_item_pressed", [i, item_instance])
		if cur_items[cur_option] == i:
			item_instance.get_node("Control/Checkmark").show()
		item_grid.add_child(item_instance)
	modulate_sprites()


func modulate_sprites():
	for i in cur_colors.size():
		modulate_color(i)
		

func modulate_color(i):
	var color_rect := color_box.get_child(i).get_node("ColorRect")
	color_rect.color = cur_colors[i]
	color_rects.append(color_rect)
	for node in get_tree().get_nodes_in_group(COLOR_OPTIONS[i]):
		node.modulate = cur_colors[i]


func request_perms_android():
	if OS.get_name() == "Android":
		var perms := OS.get_granted_permissions()
		if not "android.permission.READ_EXTERNAL_STORAGE" in perms \
		or not "android.permission.WRITE_EXTERNAL_STORAGE" in perms:
			OS.request_permissions()


func _set_grid_sep() -> void:
	item_grid.set(
		"custom_constants/hseparation",
		(item_grid.rect_size.x - 145*4) / 3
	)


func on_gender_selected(button_pressed:bool, index:int):
	if button_pressed:
		cur_gender = index
		for layer in preview.get_children():
			for i in layer.get_child_count():
				var tex = layer.get_child(i)
				if tex.texture:
					tex.texture = images[cur_gender]\
					[layer.item_indices[1]][layer.item_indices[2]]\
					[layer.layer_indices[i]]
		make_items()


func on_item_option_selected(index:int) -> void:
	cur_option = index
	make_items()


func on_color_rect_gui_input(event:InputEvent, i:int):
	if event is InputEventMouseButton and not event.pressed and event.button_index == BUTTON_LEFT:
		cur_color = i
		color_pop.popup_centered()
		color_picker.update_color(cur_colors[i])
	

func on_color_picker_color_changed(color:Color):
	cur_colors[cur_color] = color
	color_rects[cur_color].color = color
	modulate_color(cur_color)


func on_item_pressed(event:InputEvent, i:int, item:VBoxContainer):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and not event.pressed:
		if cur_items[cur_option] == i:
			item.get_node("Control/Checkmark").hide()
			cur_items[cur_option] = null
			for layer in preview.get_child(cur_option).get_children():
				layer.texture = null
		else:
			for node in get_tree().get_nodes_in_group("item"):
				node.get_node("Control/Checkmark").hide()
			item.get_node("Control/Checkmark").show()
			cur_items[cur_option] = i
			preview.get_child(cur_option).item_indices = item.item_indices
			preview.get_child(cur_option).layer_indices = item.layer_indices
			for layer in item.get_node("Control").get_children():
				if not layer.name == "Checkmark":
					preview.get_child(cur_option).get_node(layer.name).texture = layer.texture


func on_clear_all_pressed():
	for i in cur_items.size():
		if i != 1:
			cur_items[i] = null
	for layer in preview.get_children():
		if layer.name != "Body":
			for child_layer in layer.get_children():
				child_layer.texture = null
	if cur_option != 1:
		for item in item_grid.get_children():
			if item.get_node("Control/Checkmark").visible:
				item.get_node("Control/Checkmark").hide()
				break


func save_file(path:String="") -> void:
	wait_label.text = "Generating image..."
	wait_pop.popup_centered()
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	
	if OS.get_name() == "HTML5":
		save_image.save_file(path)
	else:
		thread = Thread.new()
		thread.start(save_image, "save_file", path)


func save_finished(path:String):
	if thread:
		thread.wait_to_finish()
	if OS.get_name() == "Android":
		wait_label.text = "Image saved to " + path + "!"
	elif path:
		wait_label.text = "Image saved!"
	else:
		wait_label.text = "Image downloaded!"
	yield(get_tree().create_timer(WAIT_POP_TIME), "timeout")
	wait_pop.hide()
