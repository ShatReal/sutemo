extends Control


enum Genders {FEMALE, MALE}
enum Options {ACCESSORIES, GLASSES, MOUTHS, EYES, FRONT_HAIR, OUTFITS, NECK, BLUSHES, BACK_HAIR}
enum Colors {SKIN, EYE, HAIR}

const IMG_SIZE := Vector2(1_000, 1_200)
const OPTION_GROUPS := [
	["accessories", "headphones_up", "headphones_base"],
	["glasses"],
	["mouths"],
	["eyes"],
	["front_hair", "eye_cover_hair"],
	["outfits"],
	["neck"],
	["blushes"],
	["back_hair"],
]
const COLOR_OPTIONS := ["skin", "eye", "hair"]
const WAIT_POP_TIME := 2

var cur_gender:int = Genders.FEMALE
var cur_option:int = Options.ACCESSORIES
var cur_colors := [Color("#fff9df"), Color("#ff8fcd"), Color("#eae4e6")]
var color_rects := []
var cur_color:int = Colors.SKIN
var thread: Thread

onready var save_image := $SaveImage
onready var preview := $HBox/Preview
onready var wait_pop: PopupPanel = $WaitPop
onready var wait_label: Label = $WaitPop/WaitLabel
onready var item_scroll := $HBox/MarCon/Options/ItemScroll
onready var item_options := $HBox/MarCon/Options/HBox/Dropdowns/ItemOptions
onready var color_box: HBoxContainer = $HBox/MarCon/Options/HBox/ColorPanel/ColorBox


func _ready() -> void:
	determine_save_method()
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


func set_item_option_button():
	for option in OPTION_GROUPS:
		item_options.add_item(option[0].capitalize())
	

func modulate_sprites():
	for i in cur_colors.size():
		var color_rect := color_box.get_child(i).get_node("ColorRect")
		color_rect.color = cur_colors[i]
		color_rects.append(color_rect)
		for node in get_tree().get_nodes_in_group(COLOR_OPTIONS[i]):
			node.modulate = cur_colors[i]


func connect_credits():
	$HBox/MarCon/Options/Buttons/Credits.connect("pressed", $Credits, "popup_centered")


func make_items():
	for i in Genders.size():
		for option in OPTION_GROUPS:
			pass
	

func request_perms_android():
	if OS.get_name() == "Android":
		var perms := OS.get_granted_permissions()
		if not "android.permission.READ_EXTERNAL_STORAGE" in perms \
		or not "android.permission.WRITE_EXTERNAL_STORAGE" in perms:
			OS.request_permissions()


func on_gender_selected(index:int):
	pass


func on_item_option_selected(index:int) -> void:
	pass


func on_color_rect_gui_input(event:InputEvent, i:int):
	if event is InputEventMouseButton and not event.pressed and event.button_index == BUTTON_LEFT:
		cur_color = i
	

func on_color_picker_color_changed(color:Color):
	cur_colors[cur_color] = color
	color_rects[cur_color].color = color
	for node in get_tree().get_nodes_in_group(COLOR_OPTIONS[cur_color]):
		node.modulate = cur_colors[cur_color]


func on_icon_pressed(button_pressed:bool, folder:String, textures:Array):
	pass


func on_clear_pressed(option:String):
	pass


func on_clear_all_pressed():
	pass


func save_file(path:String="") -> void:
	wait_label.text = "Generating image..."
	wait_pop.popup_centered()
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	
	var arr: Array = [path, preview]
	if OS.get_name() == "HTML5":
		save_image.save_file(arr)
	else:
		thread = Thread.new()
		thread.start(save_image, "save_file", arr)


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

