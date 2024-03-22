extends Node
## A class that provides basic inventory functions to an entity. Can only use one slot resource, so for slots with different properties add multiple. For a GUI to interact with the inventory in-game, use InventoryDisplayComponent.
class_name InventoryComponent


@export_group("InventoryComponent")
## The amount of inventory slots that this component will generate and manage.
@export var slot_amount : int
## The resource that will be generated as the inventory slot.
@export var slot_resource : InventorySlotResource


## An array of inventory resources which will be generated at runtime.
var slot_resources_array : Array


#------------------------------------------------------------------#
#---------------------------item Database--------------------------#
#------------------------------------------------------------------#

## An array containing a resource of every single item. When an item is added, this database is searched to find the item with the matching name.
const item_database : Dictionary = {
	"Water Bottle": preload("res://items/water_bottle.tres"),
	"Redberry": preload("res://items/redberry.tres"),
	"Cheese": preload("res://items/cheese.tres"),
	"Wood Claw": preload("res://items/wood_claw.tres"),
	"Wood Barricade Shield": preload("res://items/wood_barricade_shield.tres")
}



func _ready():
	generate_inventory_resources(slot_amount, slot_resource)
	#add_item("Cheese", 5)
#	add_item("refinedtopaz", 99)
#	add_item("refinedruby", 99)
#	add_item("refineddiamond", 99)
#	add_item("refinedjade", 99)
#	add_item("refinedemerald", 99)
#	add_item("refinedsapphire", 99)
#	add_item("wood", 99)
#	add_item("stone", 99)
#	add_item("reFined Ruby", 99)
	#add_item("Redberry", 5)
	add_item("Wood Claw", 7)
	add_item("Wood Barricade Shield")
	#add_item("Water Bottle", 8)

#------------------------------------------------------------------#
#------------------------Inventory Utilities-----------------------#
#------------------------------------------------------------------#


## Generates a set amount of selected resources to be used by the inventory by duplicating them.
func generate_inventory_resources(amount : int, resource : InventorySlotResource) -> void:
	if slot_amount <= 0:
		push_error("Inventory component slot generated amount is less than 0, no slots will be generated.")
	# print("Resource Generation Started")
	for i in range(amount):
		slot_resources_array.append(resource.duplicate(true))
	# print(slot_resources_array.size(), " SlotResources have been generated. Base resource: ", resource)
	# print("slot_resources_array:")
	# print(slot_resources_array)


func is_item_allowed(item : ItemResource, slot_resource : SpecializedSlotResource) -> bool:
	var property_list : Array[Dictionary] = item.get_property_list()
	for property in property_list:
		if slot_resource.allowed_item_components.has(property["class_name"]):
			return true
	return false


## Attempts to find an empty slot in the inventory by checking every slot_resource's item_resource property.
func find_empty_slot_resource():
	for slot_resource in slot_resources_array:
		if slot_resource.item_resource == null:
			# print("Found empty slot in inventory.")
			return slot_resource
	# print("Failed to find empty slot in inventory.")
	return null


## Attempts to find a slot with the entered item_resource and with an amount of items that if added the input amount to does not exceed the item stack_amount.
func find_non_full_slot_resource(item_resource : ItemResource):
	for slot_resource in slot_resources_array:
		if slot_resource.item_resource == item_resource and slot_resource.item_amount < item_resource.stack_amount:
			# print("Found non full slot_resource with the selected item: ", slot_resource)
			return slot_resource
	# print("Couldn't find non-full slot resource.")
	return null


# Attempts to find any slot with the entered item_resource.
func find_slot_resource_with_item(item_resource : ItemResource):
	for slot_resource in slot_resources_array:
		if slot_resource.item_resource == item_resource:
			# print("Found slot_resource with the selected item: ", slot_resource)
			return slot_resource
	# print("Couldn't find slot resource with item ", item_resource.item_name)
	return null


#------------------------------------------------------------------#
#---------------------Main Inventory Functions---------------------#
#------------------------------------------------------------------#


## Adds a specified amount of an item to the inventory.
func add_item(item : String, amount : int = 1):
	print("Adding ", amount, " of the item ", item)
	# Search through item database to determine if the input item is valid
	var item_in_database : ItemResource = item_database.get(item)
	if item_in_database != null:
		# Attempt to find a non full slot with the selected item
		while amount > 0:
			var non_full_slot : InventorySlotResource = find_non_full_slot_resource(item_in_database)
			# Check if slot is specialized
			if non_full_slot != null:
				if non_full_slot.is_specialized == false:
					# Calculate if the maximum possible amount that can be added to a slot is smaller than the total amount
					# This prevents adding more items to a stack than its stack_amount
					var prev_amount : int = non_full_slot.item_amount
					var max_possible_amount : int = item_in_database.stack_amount - prev_amount
					var amount_to_add : int
					if max_possible_amount < amount:
						amount_to_add = max_possible_amount
					elif max_possible_amount >= amount:
						amount_to_add = amount
					print("Resource currently has ", non_full_slot.item_amount, " items. After adding ", amount_to_add, " items, the slot will have ", non_full_slot.item_amount + amount_to_add, " items.")
					# Use edit_slot_resource_util to edit the slot_amount of the found slot_resource according to the input
					non_full_slot.item_amount = non_full_slot.item_amount + amount_to_add
					amount = amount - amount_to_add
					print("Successfully added ", amount_to_add, " of the item ", item.to_lower(), " to an non-full slot_resource.")
					print("Items left to add: ", amount)
				# If slot is specialized, check if the item can be added into the slot and override stack_amount
				elif non_full_slot.is_specialized == true and is_item_allowed(item_in_database, slot_resource) or non_full_slot.allowed_items.has(item_in_database) == true:
					# Calculate if the maximum possible amount that can be added to a slot is smaller than the total amount
					# This prevents adding more items to a stack than its stack_amount
					var prev_amount : int = non_full_slot.item_amount
					var max_possible_amount : int = non_full_slot.OverrideStackAmount - prev_amount
					var amount_to_add : int
					if max_possible_amount < amount:
						amount_to_add = max_possible_amount
					elif max_possible_amount >= amount:
						amount_to_add = amount
					print("Resource currently has ", non_full_slot.item_amount, " items. After adding ", amount_to_add, " items, the slot will have ", non_full_slot.item_amount + amount_to_add, " items.")
					# Use edit_slot_resource_util to edit the slot_amount of the found slot_resource according to the input
					non_full_slot.item_amount =  non_full_slot.item_amount + amount_to_add
					amount = amount - amount_to_add
					print("Successfully added ", amount_to_add, " of the item ", item.to_lower(), " to an non-full SpecializedSlotResource.")
					print("Items left to add: ", amount)
			# Attempt to find an empty slot in the inventory if there wasn't an avaliable slot
			var empty_slot : InventorySlotResource = find_empty_slot_resource()
			if empty_slot != null:
				if empty_slot.is_specialized == false:
					# Calculate if the maximum possible amount that can be added to a slot is smaller than the total amount
					# This prevents adding more items to a stack than its stack_amount
					var max_possible_amount : int = item_in_database.stack_amount
					var amount_to_add : int
					if max_possible_amount < amount:
						amount_to_add = max_possible_amount
					elif max_possible_amount >= amount:
						amount_to_add = amount
					# Use edit_slot_resource_util to edit the empty slot_resource according to the input
					empty_slot.item_resource = item_in_database.duplicate(true)
					empty_slot.item_amount = amount_to_add
					amount = amount - item_in_database.stack_amount
					print("Successfully added ", amount_to_add, " of the item ", item.to_lower(), " to an empty slot_resource.")
					# print("Items left to add: ", amount)
				# If slot is specialized, check if the item can be added into the slot and override stack_amount
				elif empty_slot.is_specialized == true and empty_slot.item_resource.find_components(empty_slot.allowed_item_components) != [] or empty_slot.allowed_items.has(item_in_database) == true:
					# Calculate if the maximum possible amount that can be added to a slot is smaller than the total amount
					# This prevents adding more items to a stack than its stack_amount
					var prev_amount : int = empty_slot.item_amount
					var max_possible_amount : int = empty_slot.override_stack_amount
					var amount_to_add : int
					if max_possible_amount < amount:
						amount_to_add = max_possible_amount
					elif max_possible_amount >= amount:
						amount_to_add = amount
					print("Resource currently has ", empty_slot.item_amount, " items. After adding ", amount_to_add, " items, the slot will have ", empty_slot.item_amount + amount_to_add, " items.")
					# Use edit_slot_resource_util to edit the slot_amount of the found slot_resource according to the input
					empty_slot.item_resource = item_in_database.duplicate(true)
					empty_slot.item_amount = empty_slot.item_amount + amount_to_add
					amount = amount - amount_to_add
					print("Successfully added ", amount_to_add, " of the item ", item.to_lower(), " to an non-full SpecializedSlotResource.")
					print("Items left to add: ", amount)
				else:
					print("Couldn't find a suitable slot for ", amount, " of item ", item_in_database.item_name)
					return false
			else:
				return false
	else:
		print("Could not find item %s in database." % item)



## Removes a specified amount of an item from the inventory.
func remove_item(item : String, amount : int = 1, slot_resource : InventorySlotResource = null):
	print("Removing ", amount, " of the item ", item)
	# Search through item database to determine if the input item is valid
	var item_in_database : ItemResource = item_database.get(item)
	var prev_amount : int
	if item_in_database != null:
		while amount > 0:
			if slot_resource == null:
				slot_resource = find_slot_resource_with_item(item_in_database)
			if slot_resource != null:
				var max_possible_amount : int = item_in_database.stack_amount
				var amount_to_remove : int
				prev_amount = slot_resource.item_amount
				slot_resource.item_amount = slot_resource.item_amount - amount
				if max_possible_amount < amount:
					amount_to_remove = max_possible_amount
				elif max_possible_amount > amount: 
					amount_to_remove = amount
				amount = amount - prev_amount
				print("Successfuly removed ", amount_to_remove, " items from the slot_resource ", slot_resource)
				print("Items left to remove: ", amount)

