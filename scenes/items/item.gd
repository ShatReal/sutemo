extends VBoxContainer


const CROSS_N: StreamTexture = preload("res://theme/images/cross_normal.png")
const CROSS_T: StreamTexture = preload("res://theme/images/cross_toggled.png")
const COLOR_GROUPS: Dictionary = {
	"eye": ["expressions"],
	"hair": ["eye_cover", "hairs_front", "hairs_behind"],
}
onready var main: Control = $"/root/Main"
onready var checkmark: TextureRect = $Icons/Checkmark
onready var item_button: TextureButton = $Icons/ItemButton


func _ready():
	checkmark.hide()


func init(gender:int, option:String, path:String, files:Array, folder:String) -> void:
	var label_name: String = _path_to_label(path)
	$Label.text = label_name
	
	var textures: Array = [] # [Icon, Skin, Static]
	textures.resize(3)
	for file in files:
		var cur_texture = load(path + file)
		if "skin" in file:
			textures[1] = cur_texture
			var skin_texture: TextureRect = item_button.get_node("Skin")
			skin_texture.texture = cur_texture
			skin_texture.add_to_group("skin_" + main.gender_info[gender].gender)
		elif "static" in file:
			textures[2] = cur_texture
			var static_texture: TextureRect = item_button.get_node("Static")
			static_texture.texture = cur_texture
		else:
			textures[0] = cur_texture
			item_button.texture_normal = cur_texture
			for group in COLOR_GROUPS:
				for layer in COLOR_GROUPS[group]:
					if option == layer:
						item_button.add_to_group(group + "_" + main.gender_info[gender].gender)
	
	item_button.connect("toggled", main, "_on_icon_pressed", [folder, textures])
	item_button.connect("toggled", self, "_switch_check")
	item_button.group = main.gender_info[gender].button_groups[folder]


func init_clear(option:String) -> void:
	item_button.disabled = false
	item_button.texture_normal = CROSS_N
	item_button.texture_pressed = CROSS_T
	item_button.texture_hover = CROSS_T
	item_button.connect("pressed", main, "_on_clear_pressed", [option])


func _path_to_label(path:String) -> String:
	if "pe_uniform" in path:
		return "PE Uniform"
	elif "other" in path:
		return "Headphones"
	else:
		var label_name:String = path.split("/", false)[-1].split("_", true, 1)[1].capitalize()
		label_name = label_name.replace("Twin Tail Short Hair", "Twin Tail / Short Hair")
		label_name = label_name.replace("Long Hair Hime Cut", "Long Hair / Hime Cut")
		label_name = label_name.replace(" - ", "-")
		return label_name


func _switch_check(button_pressed:bool) -> void:
	checkmark.visible = button_pressed
