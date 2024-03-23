extends Node
class_name InventoryEquipComponent


## Overrides all the other settings with settings for a special selection mode that is meant for two-handed entities.
@export var two_hand_mode : bool


## Used in equip_item to specify how the item should be equipped.
enum EquipType {
	LEFT_HAND,
	RIGHT_HAND,
	TWO_HAND,
}


var left_hand_equipped_item : InventorySlotResource
var right_hand_equipped_item : InventorySlotResource



func equip_item(slot_resource : InventorySlotResource, hand : int, replace_previous_item : bool = true):
	if two_hand_mode == true:
		match hand:
			EquipType.LEFT_HAND:
				if replace_previous_item and left_hand_equipped_item != null:
					unequip_item(left_hand_equipped_item, EquipType.LEFT_HAND)
				slot_resource.item_resource.equip_component.item_equipped_left = true
				left_hand_equipped_item = slot_resource
			EquipType.RIGHT_HAND:
				if replace_previous_item and right_hand_equipped_item != null:
					unequip_item(right_hand_equipped_item, EquipType.RIGHT_HAND)
				slot_resource.item_resource.equip_component.item_equipped_right = true
				right_hand_equipped_item = slot_resource
			EquipType.TWO_HAND:
				if replace_previous_item:
					unequip_item(left_hand_equipped_item, EquipType.LEFT_HAND)
					unequip_item(right_hand_equipped_item, EquipType.RIGHT_HAND)
				slot_resource.item_resource.equip_component.item_equipped_right = true
				right_hand_equipped_item = slot_resource
				slot_resource.item_resource.equip_component.item_equipped_left = true
				left_hand_equipped_item = slot_resource
		#print("equipped left: %s; equipped right: %s" % [slot_resource.item_resource.equip_component.item_equipped_left, slot_resource.item_resource.equip_component.item_equipped_right])


func unequip_item(slot_resource : InventorySlotResource, hand : int):
	if slot_resource.item_resource.equip_component != null:
		if two_hand_mode == true:
			match hand:
				EquipType.LEFT_HAND:
					slot_resource.item_resource.equip_component.item_equipped_left = false
					left_hand_equipped_item = null
				EquipType.RIGHT_HAND:
					slot_resource.item_resource.equip_component.item_equipped_right = false
					right_hand_equipped_item = null
				EquipType.TWO_HAND:
					slot_resource.item_resource.equip_component.item_equipped_left = false
					left_hand_equipped_item = null
					slot_resource.item_resource.equip_component.item_equipped_right = false
					right_hand_equipped_item = null

