extends Node
## A class that allows the entity to use and equip items.
class_name InventoryUseComponent



## If the player can use placeable items.
@export var use_placeables : bool

## Flags that determine the item's use mode.
enum UseType {
	PRIMARY,
	SECONDARY,
}

## Flags that determine the item's use arguments.
enum UseArguments {
	PLAYER,
	SLOT_RESOURCE,
}

## Uses an item, calling its provided use function with the specified arguments.
func use_item(slot_resource : InventorySlotResource, type : int):
	if slot_resource != null:
		if slot_resource.item_resource != null:
			if slot_resource.item_resource.use_component != null:
				var arguments_array : Array[UseArguments] = [UseArguments.PLAYER]
				if slot_resource.item_resource.consumable_component != null:
					arguments_array.append(UseArguments.SLOT_RESOURCE)
				arguments_array.append_array(slot_resource.item_resource.use_component.extra_arguments) 
				call(
				slot_resource.item_resource.item_name.to_snake_case() + ("_primary" if type == UseType.PRIMARY 
				else "_secondary" if type == UseType.SECONDARY 
				else null),
				(get_parent() if arguments_array.has(UseArguments.PLAYER) else null),
				(slot_resource if arguments_array.has(UseArguments.SLOT_RESOURCE) else null),
				)


# item func template:
# func (player : Player, slot_resource : InventorySlotResource):


func redberry_primary(slot_resource : InventorySlotResource):
	#inventory_component_node.remove_item("redberry", 1, slot_resource)
	#get_parent().variable_stats.find_stat("Hunger").stat_value += 10
	pass


func water_bottle_primary(player : Player, slot_resource : InventorySlotResource):
	player.inventory_component.remove_item("Water Bottle", 1, slot_resource)
	player.variable_stats_component.find_stat("Health").stat_value += 30


func wood_claw_primary(player : Player, slot_resource : InventorySlotResource):
	print("wood claw primary")


func wood_claw_secondary(player : Player, slot_resource : InventorySlotResource):
	print("wood claw secondary")


func wood_mining_claw_primary(player : Player, slot_resource : InventorySlotResource):
	print("wood mining claw primary")


func wood_mining_claw_secondary(player : Player, slot_resource : InventorySlotResource):
	print("wood mining claw secondary")
