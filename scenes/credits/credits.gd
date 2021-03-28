extends PopupPanel


onready var scroll_container := $HBox/VBoxContainer/ScrollContainer
onready var tween := $Tween


func _ready():
	if get_parent().name == "root":
		popup_exclusive = true
		call_deferred("popup_centered")


func on_meta_clicked(meta):
	OS.shell_open(meta)


func on_scroll_container_gui_input(event):
	if event is InputEventScreenDrag:
		tween.interpolate_property(
			scroll_container,
			"scroll_vertical",
			scroll_container.scroll_vertical,
			scroll_container.scroll_vertical - event.speed.y,
			0.5,
			Tween.TRANS_SINE,
			Tween.EASE_OUT
		)
		tween.start()
