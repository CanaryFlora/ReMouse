extends ItemStats
## A class that stores the information for resource items, such as how the item is used in crafting.
class_name ResourceStats


@export_group("Crafting Resource")
## If the item is consumed when used in crafting.
@export var ItemConsumeInCrafting : bool = true
## The item which this item will add when used in crafting.
@export var ItemReplaceWithInCrafting : StringName

func _init():
	TypeIndexArray.append(1)
