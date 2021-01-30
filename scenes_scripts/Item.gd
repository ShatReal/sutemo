extends VBoxContainer


func init(gender, option, path, folder):
	var base = $Icons/Base
	var curr_dict = Global.gender_info[gender]
	$Icons.rect_min_size = curr_dict.prev_img_size
	if path:
		if option == "hairs_behind":
			$Icons.move_child(base, 1)
		base.texture_normal = curr_dict.base
		var label_name = _path_to_label(path)
		$Label.text = label_name
		var sprite = load(path)
		$Icons/Item.texture = sprite
		# warning-ignore:return_value_discarded
		base.connect("toggled", self, "_switch_check")
		# warning-ignore:return_value_discarded
		base.connect("toggled", Global, "_on_icon_pressed", [folder, sprite])
		base.group = curr_dict.button_groups[folder]
	else:
		base.disabled = false
		base.texture_normal = Global.CROSS_N
		base.texture_pressed = Global.CROSS_T
		base.texture_hover = Global.CROSS_T
		# warning-ignore:return_value_discarded
		base.connect("pressed", Global, "_on_clear_pressed", [option])


func _path_to_label(path):
	if "pe_uniform" in path:
		return "PE Uniform"
	elif "headphones_icon" in path:
		return "Headphones"
	else:
		var label_name = path.split("/")[-1].split("_", true, 1)[1].replace(".png", "").capitalize()
		label_name = label_name.replace("Twin Tail Short Hair", "Twin Tail / Short Hair")
		label_name = label_name.replace("Long Hair Hime Cut", "Long Hair / Hime Cut")
		label_name = label_name.replace(" - ", "-")
		return label_name


func _switch_check(button_pressed):
	$Icons/Checkmark.visible = button_pressed
