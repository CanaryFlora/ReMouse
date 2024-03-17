extends Node2D

const settings_scene : PackedScene = preload("res://menu/settings_scene.tscn")

func _on_playbutton_pressed():
	get_tree().change_scene_to_file("res://world.tscn")
#	get_tree().change_scene_to_file("res://tutorial.tscn")

func _on_button_2_pressed():
	self.add_child(settings_scene.instantiate())
	self.get_node("GeneralSettings").position = Vector2(360, 139)
