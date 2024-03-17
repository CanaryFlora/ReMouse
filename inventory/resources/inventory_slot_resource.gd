extends Resource
## A basic information container to store item data. Do not edit the properties of this resource manually, use edit_slot_resource_util() from InventoryComponent.
class_name InventorySlotResource


## The resource of the item in the slot.
var item_resource : ItemResource
## The current amount of items in the slot.
var item_amount : int
## If the item in the slot is equipped in normal mode.
var item_equipped : bool

## If the item is equipped in the left hand in two hand mode.
var item_equipped_left : bool
## If the item is equipped in the right hand in two hand mode.
var item_equipped_right : bool

## If the resource is a SpecializedSlotResource.
var is_specialized : bool

