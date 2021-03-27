extends ColorRect


signal current_sv_changed(sat, val)
signal selected_sv_changed(sat, val)

const SIZE := 2.0

var x := 0.0
var y := 0.0
var mouse_down := false

onready var color_picker := $"../.."


func _draw():
	draw_line(Vector2(0, y), Vector2(rect_size.x, y), color_picker.cur_color.contrasted(), SIZE)
	draw_line(Vector2(x, 0), Vector2(x, rect_size.y), color_picker.cur_color.contrasted(), SIZE)


func _gui_input(event):
	if event.is_action_pressed("lmb"):
		mouse_down = true
		change_cur_sv(event)
	elif event.is_action_released("lmb"):
		mouse_down = false
	elif event is InputEventMouseMotion:
		if mouse_down:
			change_cur_sv(event)
		else:
			emit_signal("selected_sv_changed", event.position.x/rect_size.x, 1-event.position.y/rect_size.y)


func change_cur_sv(event):
		x = clamp(event.position.x, 0, rect_size.x)
		y = clamp(event.position.y, 0, rect_size.y)
		update()
		emit_signal("current_sv_changed", x/rect_size.x, 1-y/rect_size.y)
