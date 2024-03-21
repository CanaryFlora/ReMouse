extends Resource
## A simple class that stores the basic information of an item and its uses in crafting.
class_name ItemResource

## The item's name in-game.
@export var item_name : StringName
## Image which should be used as the texture of the item.
@export var item_texture : CompressedTexture2D
## How much of this item can be in a single stack.
@export var stack_amount : int = 99
@export var item_specific_properties : Dictionary


@export_category("Components")
@export var consumable_component : ConsumableComponent
@export var equip_component : EquipComponent
@export var tool_component : ToolComponent
@export var use_component : UseComponent
