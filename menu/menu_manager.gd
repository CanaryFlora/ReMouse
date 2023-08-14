extends Node2D

const SettingsScene : PackedScene = preload("res://menu/settings_scene.tscn")

func _on_playbutton_pressed():
	get_tree().change_scene_to_file("res://world.tscn")

func _on_button_2_pressed():
	self.add_child(SettingsScene.instantiate())
	self.get_node("GeneralSettings").position = Vector2(360, 139)
