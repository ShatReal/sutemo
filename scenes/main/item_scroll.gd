extends ScrollContainer


onready var tween := $Tween


func _input(event:InputEvent):
	if event is InputEventScreenDrag and get_v_scrollbar().visible\
	and Rect2(rect_global_position, rect_size).has_point(event.position):
		accept_event()
		tween.interpolate_property(
			self,
			"scroll_vertical",
			scroll_vertical,
			scroll_vertical - event.speed.y,
			0.5
		)
		tween.start()
