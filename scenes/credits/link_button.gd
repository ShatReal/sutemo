extends TextureButton


export(String) var link


func _pressed():
	OS.shell_open(link)
