extends TextureButton


# I want custom behavior for the buttons, so I have disabled the button and
# overridden this method.
# Specifically, I want the buttons to be in a group and be toggled, but also I
# want the user to be able to untoggle a button by clicking on it.
func _gui_input(event):
	if event is InputEventMouseButton and not event.pressed \
	and event.button_index == BUTTON_LEFT:
		pressed = !pressed
