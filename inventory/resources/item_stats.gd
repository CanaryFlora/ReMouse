extends Resource
## A simple class that stores the base properties of an item.
class_name ItemStats


@export_group("Item")
## The item's name.
@export var ItemName : StringName
## Image which should be used as the texture of the item.
@export var ItemTexture : CompressedTexture2D
## If the item is able to be equipped or not.
@export var ItemEquippable : bool
## How much of this item can be in a single stack.
@export var StackAmount : int = 99

## Array which is used by SpecializedSlotResource to see which type an item belongs to. For more information see SpecializedSlotResource.
var TypeIndexArray : Array = [0]
