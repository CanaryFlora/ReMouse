extends Node
## A class that allows the entity to use and equip items.
class_name InventoryUseComponent

## If this entity can equip items.
@export var allow_equip : bool
## The maximum amount of equipped items this entity can have.
@export var max_equipped_items : int
## If the player can use placeable items.
@export var use_placeables : bool
## Overrides all the other settings with settings for a special selection mode that is meant for two-handed entities.
@export var two_hand_mode : bool

## The InventoryComponent node of this entity.
@onready var inventory_component_node : InventoryComponent = get_parent().inventory_component

## An array of InventorySlotResources in an order from last equipped to first.
var equip_order_array : Array

	# A dictionary of methods with item names as key names. When an item's primary effect is used, this component will attempt to find a matching function in this dictionary.
var primary_item_effects_database : Dictionary = {
	"redberry": redberry_primary,
	"water_bottle": water_bottle_primary
}
## A dictionary of methods with item names as key names. When an item's secondary effect is used, this component will attempt to find a matching function in this dictionary.
var secondary_item_effects_database : Dictionary = {
}


func _ready():
	if two_hand_mode == true:
		max_equipped_items = 0
		allow_equip = true


func equip_item(slot_resource : InventorySlotResource, hand = "left"):
	if slot_resource.item_resource != null and slot_resource.item_amount > 0:
		if slot_resource.item_resource.find_components(["equip"]) != []:
			if two_hand_mode == true:
				var equipped_two_hand_array : Dictionary = find_two_hand_equipped_items()
				match hand:
					"left":
						match slot_resource.item_equipped_left:
							true:
								inventory_component_node.edit_slot_resource_util(slot_resource, slot_resource.item_resource, slot_resource.item_amount, slot_resource.item_equipped, false, false)
							false:
								if equipped_two_hand_array["equipped_left"] != null:
									inventory_component_node.edit_slot_resource_util(equipped_two_hand_array["equipped_left"], slot_resource.item_resource, slot_resource.item_amount, slot_resource.item_equipped, false, false)
								inventory_component_node.edit_slot_resource_util(slot_resource, slot_resource.item_resource, slot_resource.item_amount, slot_resource.item_equipped, true, false)
					"right":
						match slot_resource.item_equipped_right:
							true:
								inventory_component_node.edit_slot_resource_util(slot_resource, slot_resource.item_resource, slot_resource.item_amount, slot_resource.item_equipped, false, false)
							false:
								if equipped_two_hand_array["equipped_right"] != null:
									inventory_component_node.edit_slot_resource_util(equipped_two_hand_array["equipped_right"], slot_resource.item_resource, slot_resource.item_amount, slot_resource.item_equipped, false, false)
								inventory_component_node.edit_slot_resource_util(slot_resource, slot_resource.item_resource, slot_resource.item_amount, slot_resource.item_equipped, false, true)
			elif two_hand_mode == false:
				if equip_order_array.size() == max_equipped_items and slot_resource.item_equipped == false:
					inventory_component_node.edit_slot_resource_util(equip_order_array.pop_front(), slot_resource.item_resource, slot_resource.item_amount, false)
				elif slot_resource.item_equipped == true:
					equip_order_array.erase(slot_resource)
					slot_resource.item_equipped = false
					return
				inventory_component_node.edit_slot_resource_util(slot_resource, slot_resource.item_resource, slot_resource.item_amount, true)
				equip_order_array.append(slot_resource)


func use_item(slot_resource : InventorySlotResource, effect : String):
	var formatted_item_name : String = slot_resource.item_resource.item_name.to_lower().replacen(" ", "_")
	var consumable_component = slot_resource.item_resource.find_components(["consumable"]).back()
	if slot_resource.item_resource.find_components(["use"]) != []:
		if effect == "primary":
			var primary_item_effect_key : Callable = primary_item_effects_database[formatted_item_name]
			primary_item_effect_key.call(slot_resource)
		elif effect == "secondary":
			var secondary_item_effect_key : Callable = secondary_item_effects_database[formatted_item_name]
			secondary_item_effect_key.call(slot_resource)


func find_equipped_items() -> Array:
	var equipped_items_array : Array
	for slot_resource in inventory_component_node.slot_resources_array:
		if slot_resource.item_equipped == true:
			equipped_items_array.append(slot_resource)
#	print("Found ", equipped_items_array.size(), " items in the player's inventory. equipped_items_array: ", equipped_items_array)
	return equipped_items_array


func find_two_hand_equipped_items() -> Dictionary:
	var equipped_left : InventorySlotResource
	var equipped_right : InventorySlotResource
	for slot_resource in inventory_component_node.slot_resources_array:
		if slot_resource.item_equipped_left == true:
			equipped_left = slot_resource
		elif slot_resource.item_equipped_right == true:
			equipped_right = slot_resource
	return {
		"equipped_left" : equipped_left,
		"equipped_right" : equipped_right
		}


func redberry_primary(slot_resource : InventorySlotResource):
	#inventory_component_node.remove_item("redberry", 1, slot_resource)
	#get_parent().variable_stats.find_stat("Hunger").stat_value += 10
	pass


func water_bottle_primary(slot_resource : InventorySlotResource):
	#inventory_component_node.remove_item("water_bottle", 1, slot_resource)
	#get_parent().variable_stats.find_stat("Thirst").stat_value += 10
	#inventory_component_node.add_item("bottle", 1)
	pass
