extends CanvasLayer

var active = false

func _ready():
	$Panel.hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if active:
		if event.is_action_pressed("open_menu"):
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			active = false
			$Panel.show()
			get_viewport().set_input_as_handled()
	else:
		if event.is_action_pressed("open_menu"):
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			active = true
			$Panel.hide()
