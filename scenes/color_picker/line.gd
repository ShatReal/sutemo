extends Control


const SIZE := 2.0

var y := 0.0

onready var color_picker := get_node("../../..")


func _draw():
	draw_line(Vector2(0, y), Vector2(rect_size.x, y), color_picker.get_line_color(), SIZE)
