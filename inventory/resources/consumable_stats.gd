extends ResourceStats
## A class that stores the information for consumable items and what happens when the player uses them.
class_name ConsumableStats


@export_group("Consumable")
## If the item can be used multiple times.
@export var ItemMultiUse : bool
## The item which this item will add on use.
@export var ItemReplaceOnUse : StringName

func _init():
	TypeIndexArray.append(4)
