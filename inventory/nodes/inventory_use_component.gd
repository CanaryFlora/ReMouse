extends Node
## A class that allows the entity to use and equip items.
class_name InventoryUseComponent
## TODO: implement attack with lmb for left hand and rmb for right hand,
## buttons for different secondary uses (like q left hand sec, d right hand sec)
## provide a certain amount of data when an item is used based on component 
## (always provide entity that used the item)
## add item unstacking


## If the player can use placeable items.
@export var use_placeables : bool


enum UseType {
	PRIMARY,
	SECONDARY,
}

enum UseArguments {
	PLAYER,
	SLOT_RESOURCE,
}


func use_item(slot_resource : InventorySlotResource, type : int):
	if slot_resource.item_resource.use_component != null:
		var arguments_array : Array[UseArguments] = [UseArguments.PLAYER]
		if slot_resource.item_resource.consumable_component != null:
			arguments_array.append(UseArguments.SLOT_RESOURCE)
		arguments_array.append_array(slot_resource.item_resource.use_component.extra_arguments)
		slot_resource.item_resource.use_component.primary_use_function.call(
		"primary" if type == UseType.PRIMARY 
		else "secondary" if type == UseType.SECONDARY 
		else null,
		get_parent() if arguments_array.has(UseArguments.PLAYER) else null,
		slot_resource if arguments_array.has(UseArguments.SLOT_RESOURCE) else null,
		)




func redberry_primary(slot_resource : InventorySlotResource):
	#inventory_component_node.remove_item("redberry", 1, slot_resource)
	#get_parent().variable_stats.find_stat("Hunger").stat_value += 10
	pass
