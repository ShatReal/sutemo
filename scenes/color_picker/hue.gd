extends ColorRect


signal current_hue_changed(hue)
signal selected_hue_changed(hue)

const SIZE := 2.0

var y := 0.0
var mouse_down := false

onready var color_picker := $"../.."


func _draw():
	draw_line(Vector2(0, y), Vector2(rect_size.x, y), color_picker.cur_color.contrasted(), SIZE)


func _gui_input(event):
	if event.is_action_pressed("lmb"):
		mouse_down = true
		change_cur_hue(event)
	elif event.is_action_released("lmb"):
		mouse_down = false
	elif event is InputEventMouseMotion:
		if mouse_down:
			change_cur_hue(event)
		else:
			emit_signal("selected_hue_changed", event.position.y/rect_size.y)
		

func change_cur_hue(event):
		y = clamp(event.position.y, 0, rect_size.y)
		update()
		emit_signal("current_hue_changed", y/rect_size.y)
