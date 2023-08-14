extends Node
## A node that manages the inventory resources. Can only use one slot resource, so for slots with different properties add multiple. For a GUI to interact with the inventory in-game, use InventoryDisplayComponent.
class_name InventoryComponent

@export_group("InventoryComponent")
## The amount of inventory slots that this component will generate and manage.
@export var SlotAmount : int
## The resource that will be generated as the inventory slot.
@export var SlotResource : InventorySlotResource


## An array of inventory resources which will be generated at runtime.
var SlotResourcesArray : Array


#------------------------------------------------------------------#
#---------------------------Item Database--------------------------#
#------------------------------------------------------------------#
# copypaste sample: 	"" : ,

## A dictionary of resources containing the resource of every single item.
# Remove all spaces and underscores for item names.
const item_database : Dictionary = {
	"refinedtopaz" : preload("res://items/refined_topaz.tres"),
	"refinedruby" : preload("res://items/refined_ruby.tres"),
	"refineddiamond" : preload("res://items/refined_diamond.tres"),
	"refinedemerald" : preload("res://items/refined_emerald.tres"),
	"refinedjade" : preload("res://items/refined_jade.tres"),
	"refinedsapphire" : "res://items/refined_sapphire.tres",
	"wood" : preload("res://items/wood.tres"),
	"stone" : preload("res://items/stone.tres"),
	"wolffurclothing" : preload("res://items/wolf_fur_clothing.tres"),
	"woodclaw" : preload("res://items/wood_claw.tres")
}



func _ready():
	generate_inventory_resources(SlotAmount, SlotResource)
	add_item("stone", 500)
	add_item("woodclaw", 10)


#------------------------------------------------------------------#
#------------------------Inventory Utilities-----------------------#
#------------------------------------------------------------------#

## Attemps to find a key with the provided name in the inventory database, then returns the ItemStats if it found one.
func find_item_in_database(item : String):
	for Item in item_database:
		if Item.to_lower() == item.to_lower():
			print("Matching item found in database: ", Item)
			return item_database[Item]
	print("Failed to find item in item database.")
	return null

## Utility which helps edit SlotResources. Edits the input SlotResource's properties to the input properties.
func edit_slot_resource_util(SlotResource : InventorySlotResource, item = SlotResource.ItemResource, amount = SlotResource.ItemAmount, EquippedLeft = SlotResource.ItemEquippedLeft, EquippedRight = SlotResource.ItemEquippedRight):
	# Make a identical copy of the resource for debug purposes
	var UneditedSlotResource : InventorySlotResource = SlotResource.duplicate()
	UneditedSlotResource.ItemResource = SlotResource.ItemResource
	UneditedSlotResource.ItemAmount = SlotResource.ItemAmount
	UneditedSlotResource.ItemEquippedLeft = SlotResource.ItemEquippedLeft
	UneditedSlotResource.ItemEquippedRight = SlotResource.ItemEquippedRight
	# Change values of the main resource
	SlotResource.ItemResource = item
	SlotResource.ItemAmount = amount
	SlotResource.ItemEquippedLeft = EquippedLeft
	SlotResource.ItemEquippedRight = EquippedRight
	if SlotResource.ItemAmount <= 0:
		SlotResource.ItemResource = null
		SlotResource.ItemAmount = 0
		SlotResource.ItemEquippedLeft = false
		SlotResource.ItemEquippedRight = false
	# If any changes were made, return new SlotResource
	if UneditedSlotResource.ItemResource !=  SlotResource.ItemResource or UneditedSlotResource.ItemAmount != SlotResource.ItemAmount or UneditedSlotResource.ItemEquippedLeft != SlotResource.ItemEquippedLeft or UneditedSlotResource.ItemEquippedRight != SlotResource.ItemEquippedRight:
		print("Successfully edited SlotResource ", SlotResource, ". Current properties: ", "Item = ", SlotResource.ItemResource, " Amount = ", SlotResource.ItemAmount, " EquippedRight = ", SlotResource.ItemEquippedRight, " EquippedLeft = ", SlotResource.ItemEquippedLeft)
		print("Previous properties for this resource: ", "Item = ", UneditedSlotResource.ItemResource, " Amount = ", UneditedSlotResource.ItemAmount, " EquippedRight = ", UneditedSlotResource.ItemEquippedRight, " EquippedLeft = ", UneditedSlotResource.ItemEquippedLeft)
		return SlotResource
	else:
		# If not, return null
		print("Failed to edit SlotResource, no changes were made.")
		print("Properties: SlotResource ", SlotResource, " Item = ", SlotResource.ItemResource, " Amount = ", SlotResource.ItemAmount, " EquippedRight = ", SlotResource.ItemEquippedRight, " EquippedLeft = ", SlotResource.ItemEquippedLeft)
		return null

## Generates a set amount of selected resources to be used by the inventory by duplicating them.
func generate_inventory_resources(amount : int, resource : InventorySlotResource) -> void:
	print("Resource Generation Started")
	for i in range(amount):
		SlotResourcesArray.append(resource.duplicate())
	print(SlotResourcesArray.size(), " SlotResources have been generated. Base resource: ", resource)
	print("SlotResourcesArray:")
	print(SlotResourcesArray)

## Attempts to find an empty slot in the inventory by checking every SlotResource's ItemResource property.
func find_empty_slot_resource():
	for SlotResource in SlotResourcesArray:
		if SlotResource.ItemResource == null:
			print("Found empty slot in inventory.")
			if SlotResource.IsSpecialized == true:
				print("This SlotResource is specialized!")
			return SlotResource
	print("Failed to find empty slot in inventory.")
	return null

## Attempts to find a slot with the entered ItemResource and with an amount of items that if added the input amount to does not exceed the item StackAmount.
func find_non_full_slot_resource(ItemResource : ItemStats):
	for SlotResource in SlotResourcesArray:
		if SlotResource.ItemResource == ItemResource and SlotResource.ItemAmount < ItemResource.StackAmount:
			print("Found non full SlotResource with the selected item: ", SlotResource)
			if SlotResource.IsSpecialized == true:
				print("This SlotResource is specialized!")
			return SlotResource
	print("Couldn't find non-full slot resource.")
	return null

# Attempts to find any slot with the entered ItemResource.
func find_slot_resource_with_item(ItemResource : ItemStats):
	for SlotResource in SlotResourcesArray:
		if SlotResource.ItemResource == ItemResource:
			print("Found SlotResource with the selected item: ", SlotResource)
			if SlotResource.IsSpecialized == true:
				print("This SlotResource is specialized!")
			return SlotResource

	print("Couldn't find slot resource with item ", ItemResource.ItemName)
	return null

#------------------------------------------------------------------#
#---------------------Main Inventory Functions---------------------#
#------------------------------------------------------------------#


## Adds a specified amount of an item to the inventory.
func add_item(item : String, amount = 1):
	print("Adding ", amount, " of the item ", item.to_lower())
	# Search through item database to determine if the input item is valid
	var ItemInDatabase : ItemStats = find_item_in_database(item)
	if ItemInDatabase != null:
		# Attempt to find a non full slot with the selected item
		while amount > 0:
			var NonFullSlot : InventorySlotResource = find_non_full_slot_resource(ItemInDatabase)
			# Check if slot is specializedt
			if NonFullSlot != null:
				if NonFullSlot.IsSpecialized == false:
					# Calculate if the maximum possible amount that can be added to a slot is smaller than the total amount
					# This prevents adding more items to a stack than its StackAmount
					var PrevAmount : int = NonFullSlot.ItemAmount
					var MaxPossibleAmount : int = ItemInDatabase.StackAmount - PrevAmount
					var AmountToAdd : int
					if MaxPossibleAmount < amount:
						AmountToAdd = MaxPossibleAmount
					elif MaxPossibleAmount >= amount:
						AmountToAdd = amount
					print("Resource currently has ", NonFullSlot.ItemAmount, " items. After adding ", AmountToAdd, " items, the slot will have ", NonFullSlot.ItemAmount + AmountToAdd, " items.")
					# Use edit_slot_resource_util to edit the SlotAmount of the found SlotResource according to the input
					if edit_slot_resource_util(NonFullSlot, ItemInDatabase, NonFullSlot.ItemAmount + AmountToAdd) != null:
						amount = amount - AmountToAdd
						print("Successfully added ", AmountToAdd, " of the item ", item.to_lower(), " to an non-full SlotResource.")
						print("Items left to add: ", amount)
					else:
						print("Failed adding", AmountToAdd, " ", item, " to ", NonFullSlot)
						return false
				# If slot is specialized, check if the item can be added into the slot and override StackAmount
				elif NonFullSlot.IsSpecialized == true and ItemInDatabase.TypeIndexArray.find(NonFullSlot.AllowedItemType) != -1 or NonFullSlot.AllowedItems.find(ItemInDatabase.ItemName) != -1:
					# Calculate if the maximum possible amount that can be added to a slot is smaller than the total amount
					# This prevents adding more items to a stack than its StackAmount
					var PrevAmount : int = NonFullSlot.ItemAmount
					var MaxPossibleAmount : int = NonFullSlot.OverrideStackAmount - PrevAmount
					var AmountToAdd : int
					if MaxPossibleAmount < amount:
						AmountToAdd = MaxPossibleAmount
					elif MaxPossibleAmount >= amount:
						AmountToAdd = amount
					print("Resource currently has ", NonFullSlot.ItemAmount, " items. After adding ", AmountToAdd, " items, the slot will have ", NonFullSlot.ItemAmount + AmountToAdd, " items.")
					# Use edit_slot_resource_util to edit the SlotAmount of the found SlotResource according to the input
					if edit_slot_resource_util(NonFullSlot, ItemInDatabase, NonFullSlot.ItemAmount + AmountToAdd) != null:
						amount = amount - AmountToAdd
						print("Successfully added ", AmountToAdd, " of the item ", item.to_lower(), " to an non-full SpecializedSlotResource.")
						print("Items left to add: ", amount)
					else:
						print("Failed adding", AmountToAdd, " ", item, " to ", NonFullSlot)
						return false
			# Attempt to find an empty slot in the inventory if there wasn't an avaliable slot
			var EmptySlot : InventorySlotResource = find_empty_slot_resource()
			if EmptySlot != null:
				if EmptySlot.IsSpecialized == false:
					# Calculate if the maximum possible amount that can be added to a slot is smaller than the total amount
					# This prevents adding more items to a stack than its StackAmount
					var MaxPossibleAmount : int = ItemInDatabase.StackAmount
					var AmountToAdd : int
					if MaxPossibleAmount < amount:
						AmountToAdd = MaxPossibleAmount
					elif MaxPossibleAmount >= amount:
						AmountToAdd = amount
					# Use edit_slot_resource_util to edit the empty SlotResource according to the input
					if edit_slot_resource_util(EmptySlot, ItemInDatabase, AmountToAdd, false, false) != null:
						amount = amount - ItemInDatabase.StackAmount
						print("Successfully added ", AmountToAdd, " of the item ", item.to_lower(), " to an empty SlotResource.")
						print("Items left to add: ", amount)
					else:
						print("Failed adding", AmountToAdd, " ", item, " to ", EmptySlot)
						return false
				# If slot is specialized, check if the item can be added into the slot and override StackAmount
				elif EmptySlot.IsSpecialized == true and ItemInDatabase.TypeIndexArray.find(EmptySlot.AllowedItemType) != -1 or EmptySlot.AllowedItems.find(ItemInDatabase.ItemName) != -1:
					# Calculate if the maximum possible amount that can be added to a slot is smaller than the total amount
					# This prevents adding more items to a stack than its StackAmount
					var PrevAmount : int = EmptySlot.ItemAmount
					var MaxPossibleAmount : int = EmptySlot.OverrideStackAmount
					var AmountToAdd : int
					if MaxPossibleAmount < amount:
						AmountToAdd = MaxPossibleAmount
					elif MaxPossibleAmount >= amount:
						AmountToAdd = amount
					print("Resource currently has ", EmptySlot.ItemAmount, " items. After adding ", AmountToAdd, " items, the slot will have ", EmptySlot.ItemAmount + AmountToAdd, " items.")
					# Use edit_slot_resource_util to edit the SlotAmount of the found SlotResource according to the input
					if edit_slot_resource_util(EmptySlot, ItemInDatabase, EmptySlot.ItemAmount + AmountToAdd) != null:
						amount = amount - AmountToAdd
						print("Successfully added ", AmountToAdd, " of the item ", item.to_lower(), " to an non-full SpecializedSlotResource.")
						print("Items left to add: ", amount)
					else:
						print("Failed adding ", AmountToAdd, " ", ItemInDatabase.ItemName, " to ", EmptySlot, ".")
						return false
				else:
					print("Couldn't find a suitable slot for ", amount, " of item ", ItemInDatabase.ItemName)
					return false
	else:
		return false
		print("Added all items to inventory.")
		return true 

## Removes a specified amount of an item from the inventory.
func remove_item(item : String, amount = 1):
	print("Removing ", amount, " of the item ", item.to_lower())
	# Search through item database to determine if the input item is valid
	var ItemInDatabase : ItemStats = find_item_in_database(item.to_lower())
	var ItemSlot : InventorySlotResource
	var PrevAmount : int
	if ItemInDatabase != null:
		while amount > 0:
			ItemSlot = find_slot_resource_with_item(ItemInDatabase)
			if ItemSlot != null:
				var MaxPossibleAmount : int = ItemInDatabase.StackAmount
				var AmountToRemove : int
				PrevAmount = ItemSlot.ItemAmount
				if edit_slot_resource_util(ItemSlot, ItemInDatabase, ItemSlot.ItemAmount - amount, false, false) != null:
					if MaxPossibleAmount < amount:
						AmountToRemove = MaxPossibleAmount
					elif MaxPossibleAmount > amount: 
						AmountToRemove = amount
					amount = amount - PrevAmount
					print("Successfuly removed ", AmountToRemove, " items from the SlotResource ", ItemSlot)
					print("Items left to remove: ", amount)
				else:
					return false
			else:
				return false
	else:
		return false
		print("Removed all items from inventory.")
		return true
