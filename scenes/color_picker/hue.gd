extends ColorRect


signal current_hue_changed(hue)
signal selected_hue_changed(hue)

var mouse_down := false

onready var line = get_child(0)


func _gui_input(event:InputEvent):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.pressed:
			mouse_down = true
			change_cur_hue(event.position)
		else:
			mouse_down = false
	elif event is InputEventMouseMotion:
		if mouse_down:
			change_cur_hue(event.position)
		else:
			emit_signal("selected_hue_changed", event.position.y/rect_size.y)
		

func change_cur_hue(pos:Vector2):
		line.y = clamp(pos.y, 0, rect_size.y)
		line.update()
		emit_signal("current_hue_changed", pos.y/rect_size.y)
