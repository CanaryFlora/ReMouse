extends ItemComponent
## A general class for consumable items.
class_name ConsumableComponent

var component_name : String = "consumable"

## If LimitedUses is true, how many times this item can be used. 
@export var item_use_amount : int
## The item which this item will add on use.
@export var items_replace_on_no_uses : Array[ItemResource]

