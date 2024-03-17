extends Node2D

func _ready():
	Panku.gd_exprenv.register_env("World", self)

