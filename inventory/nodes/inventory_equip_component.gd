extends Node
class_name InventoryEquipComponent


## The maximum amount of equipped items this entity can have.
#@export var max_equipped_items : int
## Overrides all the other settings with settings for a special selection mode that is meant for two-handed entities.
@export var two_hand_mode : bool


## Used in equip_item to specify how the item should be equipped.
enum EquipType {
	LEFT_HAND,
	RIGHT_HAND,
	TWO_HAND,
}

enum UseType {
	PRIMARY,
	SECONDARY,
}


var left_hand_equipped_item : InventorySlotResource
var right_hand_equipped_item : InventorySlotResource



func equip_item(slot_resource : InventorySlotResource, hand : int, replace_previous_item : bool = true):
	if slot_resource.item_resource.equip_component != null:
		if two_hand_mode == true:
			match hand:
				EquipType.LEFT_HAND:
					if replace_previous_item and left_hand_equipped_item != null:
						unequip_item(slot_resource, EquipType.LEFT_HAND)
					slot_resource.item_equipped_left = true
					left_hand_equipped_item = slot_resource
				EquipType.RIGHT_HAND:
					if replace_previous_item and right_hand_equipped_item != null:
						unequip_item(slot_resource, EquipType.RIGHT_HAND)
					slot_resource.item_equipped_right = true
					right_hand_equipped_item = slot_resource
				EquipType.TWO_HAND:
					if replace_previous_item:
						unequip_item(slot_resource, EquipType.TWO_HAND)
					slot_resource.item_equipped_right = true
					right_hand_equipped_item = slot_resource
					slot_resource.item_equipped_left = true
					left_hand_equipped_item = slot_resource
	print("equipped left: %s; equipped right: %s" % [slot_resource.item_equipped_left, slot_resource.item_equipped_right])
		#elif two_hand_mode == false:
			#if equip_order_array.size() == max_equipped_items and slot_resource.item_equipped == false:
				#inventory_component_node.edit_slot_resource_util(equip_order_array.pop_front(), slot_resource.item_resource, slot_resource.item_amount, false)
			#elif slot_resource.item_equipped == true:
				#equip_order_array.erase(slot_resource)
				#slot_resource.item_equipped = false
				#return
			#inventory_component_node.edit_slot_resource_util(slot_resource, slot_resource.item_resource, slot_resource.item_amount, true)
			#equip_order_array.append(slot_resource)


func unequip_item(slot_resource : InventorySlotResource, hand : int):
	if slot_resource.item_resource.equip_component != null:
		if two_hand_mode == true:
			match hand:
				EquipType.LEFT_HAND:
					left_hand_equipped_item.item_equipped_left = false
					left_hand_equipped_item = null
				EquipType.RIGHT_HAND:
					right_hand_equipped_item.item_equipped_right = false
					right_hand_equipped_item = null
				EquipType.TWO_HAND:
					left_hand_equipped_item.item_equipped_left = false
					left_hand_equipped_item = null
					right_hand_equipped_item.item_equipped_right = false
					right_hand_equipped_item = null
					
