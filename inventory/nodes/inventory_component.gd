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
const item_database : Array[ItemResource] = [
	preload("res://items/cheese.tres"),
	preload("res://items/wood_claw.tres"),
	preload("res://items/redberry.tres"),
	preload("res://items/water_bottle.tres"),
	preload("res://items/bottle.tres")
]


func _ready():
	generate_inventory_resources(slot_amount, slot_resource)
	add_item("cheese", 5)
#	add_item("refinedtopaz", 99)
#	add_item("refinedruby", 99)
#	add_item("refineddiamond", 99)
#	add_item("refinedjade", 99)
#	add_item("refinedemerald", 99)
#	add_item("refinedsapphire", 99)
#	add_item("wood", 99)
#	add_item("stone", 99)
#	add_item("reFined Ruby", 99)
	add_item("redberry", 5)
	add_item("wOod_claw", 1)
	add_item("water_bottle", 8)

#------------------------------------------------------------------#
#------------------------Inventory Utilities-----------------------#
#------------------------------------------------------------------#


## Attemps to find a key with the provided name in the inventory database, then returns the ItemStats if it found one.
func find_item_in_database(item_name : String):
	for item in item_database:
		if item.item_name.to_lower().replace(" ", "_") == item_name.to_lower().replace(" ", "_"):
			# print("Matching item found in database: ", item)
			return item
	# print("Failed to find item in item database.")
	return null


## Utility which helps edit SlotResources. Edits the input slot_resource's properties to the input properties.
func edit_slot_resource_util(slot_resource : InventorySlotResource, item = slot_resource.item_resource, amount = slot_resource.item_amount, equipped = slot_resource.item_equipped, equipped_left = slot_resource.item_equipped_left, equipped_right = slot_resource.item_equipped_right):
	# Make a identical copy of the resource for debug purposes
	var unedited_slot_resource : InventorySlotResource = slot_resource.duplicate()
	unedited_slot_resource.item_resource = slot_resource.item_resource
	unedited_slot_resource.item_amount = slot_resource.item_amount
	unedited_slot_resource.item_equipped = slot_resource.item_equipped
	unedited_slot_resource.item_equipped_left = slot_resource.item_equipped_left
	unedited_slot_resource.item_equipped_right = slot_resource.item_equipped_right
	# Change values of the main resource
	slot_resource.item_resource = item
	slot_resource.item_amount = amount
	slot_resource.item_equipped = equipped
	slot_resource.item_equipped_left = equipped_left
	slot_resource.item_equipped_right = equipped_right
	if slot_resource.item_amount <= 0 or slot_resource.item_resource == null:
		slot_resource.item_resource = null
		slot_resource.item_amount = 0
		slot_resource.item_equipped = false
		slot_resource.item_equipped_left = false
		slot_resource.item_equipped_right = false
	# If any changes were made, return new slot_resource
	if unedited_slot_resource.item_resource !=  slot_resource.item_resource or unedited_slot_resource.item_amount != slot_resource.item_amount or unedited_slot_resource.item_equipped != slot_resource.item_equipped or unedited_slot_resource.item_equipped_left != slot_resource.item_equipped_left or unedited_slot_resource.item_equipped_right != slot_resource.item_equipped_right:
		# print("Successfully edited slot_resource ", slot_resource, ". Current properties: ", "item = ", slot_resource.item_resource, " Amount = ", slot_resource.item_amount,  " Equipped = ", slot_resource.item_equipped, " equipped_left = ", slot_resource.item_equipped_left, " equipped_right = ", slot_resource.item_equipped_right)
		# print("Previous properties for this resource: ", "item = ", unedited_slot_resource.item_resource, " Amount = ", unedited_slot_resource.item_amount, " Equipped = ", unedited_slot_resource.item_equipped, " equipped_left = ", unedited_slot_resource.item_equipped_left, " equipped_right = ", unedited_slot_resource.item_equipped_right)
		return slot_resource
	else:
		# If not, return null
		# print("Failed to edit slot_resource, no changes were made.")
		# print("Properties: slot_resource ", slot_resource, " item = ", slot_resource.item_resource, " Amount = ", slot_resource.item_amount, " Equipped = ", slot_resource.item_equipped, " equipped_left = ", slot_resource.item_equipped_left, " equipped_right = ", slot_resource.item_equipped_right)
		return null


## Generates a set amount of selected resources to be used by the inventory by duplicating them.
func generate_inventory_resources(amount : int, resource : InventorySlotResource) -> void:
	# print("Resource Generation Started")
	for i in range(amount):
		slot_resources_array.append(resource.duplicate())
	# print(slot_resources_array.size(), " SlotResources have been generated. Base resource: ", resource)
	# print("slot_resources_array:")
	# print(slot_resources_array)


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
	# print("Adding ", amount, " of the item ", item.to_lower())
	# Search through item database to determine if the input item is valid
	var item_in_database : ItemResource = find_item_in_database(item)
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
					# print("Resource currently has ", non_full_slot.item_amount, " items. After adding ", amount_to_add, " items, the slot will have ", non_full_slot.item_amount + amount_to_add, " items.")
					# Use edit_slot_resource_util to edit the slot_amount of the found slot_resource according to the input
					if edit_slot_resource_util(non_full_slot, item_in_database, non_full_slot.item_amount + amount_to_add) != null:
						amount = amount - amount_to_add
						# print("Successfully added ", amount_to_add, " of the item ", item.to_lower(), " to an non-full slot_resource.")
						# print("Items left to add: ", amount)
					else:
						# print("Failed adding ", amount_to_add, " ", item, " to ", non_full_slot)
						return false
				# If slot is specialized, check if the item can be added into the slot and override stack_amount
				elif non_full_slot.is_specialized == true and non_full_slot.item_resource.find_components(non_full_slot.allowed_item_components) != [] or non_full_slot.allowed_items.has(item_in_database) == true:
					# Calculate if the maximum possible amount that can be added to a slot is smaller than the total amount
					# This prevents adding more items to a stack than its stack_amount
					var prev_amount : int = non_full_slot.item_amount
					var max_possible_amount : int = non_full_slot.OverrideStackAmount - prev_amount
					var amount_to_add : int
					if max_possible_amount < amount:
						amount_to_add = max_possible_amount
					elif max_possible_amount >= amount:
						amount_to_add = amount
					# print("Resource currently has ", non_full_slot.item_amount, " items. After adding ", amount_to_add, " items, the slot will have ", non_full_slot.item_amount + amount_to_add, " items.")
					# Use edit_slot_resource_util to edit the slot_amount of the found slot_resource according to the input
					if edit_slot_resource_util(non_full_slot, item_in_database, non_full_slot.item_amount + amount_to_add) != null:
						amount = amount - amount_to_add
						# print("Successfully added ", amount_to_add, " of the item ", item.to_lower(), " to an non-full SpecializedSlotResource.")
						# print("Items left to add: ", amount)
					else:
						# print("Failed adding ", amount_to_add, " ", item, " to ", non_full_slot)
						return false
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
					if edit_slot_resource_util(empty_slot, item_in_database, amount_to_add, false) != null:
						amount = amount - item_in_database.stack_amount
						# print("Successfully added ", amount_to_add, " of the item ", item.to_lower(), " to an empty slot_resource.")
						# print("Items left to add: ", amount)
					else:
						# print("Failed adding ", amount_to_add, " ", item, " to ", empty_slot)
						return false
				# If slot is specialized, check if the item can be added into the slot and override stack_amount
				elif empty_slot.is_specialized == true and empty_slot.item_resource.find_components(empty_slot.allowed_item_components) != [] or empty_slot.allowed_items.has(item_in_database) == true:
					# Calculate if the maximum possible amount that can be added to a slot is smaller than the total amount
					# This prevents adding more items to a stack than its stack_amount
					var prev_amount : int = empty_slot.item_amount
					var max_possible_amount : int = empty_slot.OverrideStackAmount
					var amount_to_add : int
					if max_possible_amount < amount:
						amount_to_add = max_possible_amount
					elif max_possible_amount >= amount:
						amount_to_add = amount
					# print("Resource currently has ", empty_slot.item_amount, " items. After adding ", amount_to_add, " items, the slot will have ", empty_slot.item_amount + amount_to_add, " items.")
					# Use edit_slot_resource_util to edit the slot_amount of the found slot_resource according to the input
					if edit_slot_resource_util(empty_slot, item_in_database, empty_slot.item_amount + amount_to_add) != null:
						amount = amount - amount_to_add
						# print("Successfully added ", amount_to_add, " of the item ", item.to_lower(), " to an non-full SpecializedSlotResource.")
						# print("Items left to add: ", amount)
					else:
						# print("Failed adding ", amount_to_add, " ", item_in_database.item_name, " to ", empty_slot, ".")
						return false
				else:
					# print("Couldn't find a suitable slot for ", amount, " of item ", item_in_database.item_name)
					return false
			else:
				return false
		# print("Added all items to inventory.")
		return true 


## Removes a specified amount of an item from the inventory.
func remove_item(item : String, amount : int = 1, slot_resource : InventorySlotResource = null):
	# print("Removing ", amount, " of the item ", item.to_lower())
	# Search through item database to determine if the input item is valid
	var item_in_database : ItemResource = find_item_in_database(item.to_lower())
	var prev_amount : int
	if item_in_database != null:
		while amount > 0:
			if slot_resource == null:
				slot_resource = find_slot_resource_with_item(item_in_database)
			if slot_resource != null:
				var max_possible_amount : int = item_in_database.stack_amount
				var amount_to_remove : int
				prev_amount = slot_resource.item_amount
				if edit_slot_resource_util(slot_resource, item_in_database, slot_resource.item_amount - amount, false) != null:
					if max_possible_amount < amount:
						amount_to_remove = max_possible_amount
					elif max_possible_amount > amount: 
						amount_to_remove = amount
					amount = amount - prev_amount
					# print("Successfuly removed ", amount_to_remove, " items from the slot_resource ", slot_resource)
					# print("Items left to remove: ", amount)
				else:
					return false
			else:
				return false

