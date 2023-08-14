extends InventorySlotResource
## A resource for specialized slots, such as an armor slot. Can be used with InventoryComponent through code.
class_name SpecializedSlotResource

## The item types that can be stored in this slot.
@export_group("SpecializedSlotResource")
@export_enum("Any Item:0", "Resource:1", "Tool:2", "Armor:3", "Consumable:4", "No Items:5") var AllowedItemType : int = 0
## Specific items which can be stored in this slot. Overrides the item type selection. 
@export var AllowedItems : PackedStringArray
## The maximum amount of items which can be in the slot. Overrides everything.
@export var OverrideStackAmount : int = 99


func _init():
	IsSpecialized = true

