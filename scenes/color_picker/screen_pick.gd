extends Button


signal screen_color_picked(c)
signal screen_color_hovered(c)

var picking := false


func _input(event):
	if picking:
		accept_event()
		if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and not event.pressed:
			emit_signal("screen_color_picked", get_screen_color(event.position))
			pressed = false
		elif event is InputEventMouseMotion:
			emit_signal("screen_color_hovered", get_screen_color(event.position))


func get_screen_color(pos:Vector2) -> Color:
	var img := get_viewport().get_texture().get_data()
	img.flip_y()
	img.lock()
	var c := img.get_pixelv(pos)
	img.unlock()
	return c
	

func _toggled(button_pressed:bool):
	picking = button_pressed
