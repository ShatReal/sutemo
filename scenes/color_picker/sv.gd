extends ColorRect


signal current_sv_changed(sat, val)
signal selected_sv_changed(sat, val)

var mouse_down := false

onready var lines = get_child(0)


func _gui_input(event:InputEvent):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.pressed:
			mouse_down = true
			change_cur_sv(event.position)
		else:
			mouse_down = false
	elif event is InputEventMouseMotion:
		if mouse_down:
			change_cur_sv(event.position)
		else:
			emit_signal("selected_sv_changed", event.position.x/rect_size.x, 1-event.position.y/rect_size.y)


func change_cur_sv(pos:Vector2):
		lines.x = clamp(pos.x, 0, rect_size.x)
		lines.y = clamp(pos.y, 0, rect_size.y)
		lines.update()
		emit_signal("current_sv_changed", pos.x/rect_size.x, 1-pos.y/rect_size.y)
