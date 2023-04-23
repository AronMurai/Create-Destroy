extends Node3D

func _ready():
	for ingredient in get_children():
		ingredient.bobAmplitude = randf_range(0.03, 0.05);

