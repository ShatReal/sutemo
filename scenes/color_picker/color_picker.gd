extends ColorPicker


var hsv_button
var raw_button


func _ready() -> void:
	get_child(0).get_child(0).mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	get_child(0).get_child(1).mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	get_child(1).get_child(0).mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	get_child(1).get_child(1).mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
	var v_box: VBoxContainer = get_child(4)
	for i in range(v_box.get_child_count() - 1):
		var child: HBoxContainer = v_box.get_child(i)
		child.get_child(1).mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		child.get_child(2).mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
	var h_box: HBoxContainer = v_box.get_child(4)
	for i in range(h_box.get_child_count()-1):
		h_box.get_child(i).mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	hsv_button = h_box.get_child(0)
	hsv_button.connect("toggled", self, "_on_hsv_mode")
	raw_button = h_box.get_child(1)
	raw_button.connect("toggled", self, "_on_raw_mode")

	get_child(6).get_child(0).mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	get_child(7).get_child(0).mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND


func _on_hsv_mode(button_pressed:bool) -> void:
	if button_pressed:
		hsv_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		raw_button.mouse_default_cursor_shape = Control.CURSOR_FORBIDDEN
	else:
		raw_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND


func _on_raw_mode(button_pressed:bool) -> void:
	if button_pressed:
		raw_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		hsv_button.mouse_default_cursor_shape = Control.CURSOR_FORBIDDEN
	else:
		hsv_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
