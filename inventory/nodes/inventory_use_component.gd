extends Node
## A class that allows the entity to use and equip items.
class_name InventoryUseComponent
## TODO: implement attack with lmb for left hand and rmb for right hand,
## buttons for different secondary uses (like q left hand sec, d right hand sec)
## find good solution for right hand equip (maybe a key to switch into right hand equip mode?)
## provide a certain amount of data when an item is used based on component 
## (always provide entity that used the item)
## make database static var and make it so you can add items to it at runtime
## same for effects and stuff
## add item unstacking
## remove one-slot equipping and replace it with left hand


## If the player can use placeable items.
@export var use_placeables : bool


## The InventoryComponent node of this entity.
@onready var inventory_component_node : InventoryComponent = get_parent().inventory_component


## An array of InventorySlotResources in an order from last equipped to first.
#var equip_order_array : Array
var left_hand_equipped_item : InventorySlotResource
var right_hand_equipped_item : InventorySlotResource


# A dictionary of methods with item names as key names. When an item's primary effect is used, this component will attempt to find a matching function in this dictionary.
var primary_item_effects_database : Dictionary = {
	"redberry": redberry_primary,
	"water_bottle": water_bottle_primary
}


## A dictionary of methods with item names as key names. When an item's secondary effect is used, this component will attempt to find a matching function in this dictionary.
var secondary_item_effects_database : Dictionary = {
}


func use_item(slot_resource : InventorySlotResource, effect : String):
	var formatted_item_name : String = slot_resource.item_resource.item_name.to_lower().replacen(" ", "_")
	if slot_resource.item_resource.use_component != null:
		if effect == "primary":
			var primary_item_effect_key : Callable = primary_item_effects_database[formatted_item_name]
			primary_item_effect_key.call(slot_resource)
		elif effect == "secondary":
			var secondary_item_effect_key : Callable = secondary_item_effects_database[formatted_item_name]
			secondary_item_effect_key.call(slot_resource)




func redberry_primary(slot_resource : InventorySlotResource):
	#inventory_component_node.remove_item("redberry", 1, slot_resource)
	#get_parent().variable_stats.find_stat("Hunger").stat_value += 10
	pass


func water_bottle_primary(slot_resource : InventorySlotResource):
	#inventory_component_node.remove_item("water_bottle", 1, slot_resource)
	#get_parent().variable_stats.find_stat("Thirst").stat_value += 10
	#inventory_component_node.add_item("bottle", 1)
	pass
