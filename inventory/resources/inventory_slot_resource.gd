extends Resource
## A basic information container to store item data.
class_name InventorySlotResource


## The resource of the item in the slot.
var ItemResource : ItemStats
## The current amount of items in the slot.
var ItemAmount : int
## If the item in the slot is currently equipped in the left hand.
var ItemEquippedLeft : bool
## If the item in the slot is currently equipped in the right hand.
var ItemEquippedRight : bool


## If the resource is a SpecializedSlotResource.
var IsSpecialized : bool
