extends Node2D

func _ready():
	_global.viewport_container = $SubViewportContainer
	print(_global.viewport_container)
	_global.viewport = $SubViewportContainer/SubViewport
