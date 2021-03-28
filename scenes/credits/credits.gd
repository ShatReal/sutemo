extends PopupPanel


func _ready():
	if get_parent().name == "root":
		popup_exclusive = true
		call_deferred("popup_centered")


func on_meta_clicked(meta):
	OS.shell_open(meta)
