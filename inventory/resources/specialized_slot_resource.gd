extends InventorySlotResource
## A resource for specialized slots, such as an armor slot. Can be used with InventoryComponent through code.
class_name SpecializedSlotResource

@export_group("SpecializedSlotResource")
## The components items must have to be stored in this slot.
@export var allowed_item_components : Array[ItemComponent]
## Specific items which can be stored in this slot. Overrides the item type selection. 
@export var allowed_items : Array[ItemResource]
## The maximum amount of items which can be in the slot. Overrides everything.
@export var override_stack_amount : int = 99


func _init():
	is_specialized = true

