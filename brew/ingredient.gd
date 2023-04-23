extends MeshInstance3D

@onready var initialHeight = position.y

var bobAmplitude = randf_range(0.03, 0.05);
var bobHeight = 0
var time = 0

func _process(delta):
	time += 5 * delta
	bobHeight = bobAmplitude * sin(time)
	position.y = initialHeight + bobHeight
	rotation_degrees.x += delta * 50.0
