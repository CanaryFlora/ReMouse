extends Sprite2D
# this script is only for hiding panku console overlay

func _ready():
	Panku.root = get_tree().get_root()
	Panku.ConsoleOverlay = Panku.root.get_node("Panku").get_node("LogOverlay")
	Panku.ConsoleOverlay.hide()
	Panku.OverlayHidden = true
	return



