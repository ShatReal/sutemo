extends PopupPanel


# There appears to be some bug with clicking URLs in RichTextLabels so this is
# my workaround.
func _ready():
# warning-ignore:return_value_discarded
	$"HBoxContainer/InfoContainer/UseInfo".connect("meta_clicked", self, "_on_meta_clicked")
# warning-ignore:return_value_discarded
	$"HBoxContainer/CreditsContainer/Links".connect("meta_clicked", self, "_on_meta_clicked")

func _on_meta_clicked(meta):
# warning-ignore:return_value_discarded
	OS.shell_open(meta)
