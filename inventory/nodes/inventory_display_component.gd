extends Node
## A class for creating a GUI to interact with an inventory.
class_name InventoryDisplayComponent

var display_slots_array : Array[Node]

## The node that InventorySlotScenes will be added as a child of.
@export var slot_scene_parent : Node
## The scene which will be used as the GUI inventory slot. See the code for InventoryDisplayComponent for guidelines on how to create a custom inventory scene.
@export var inventory_slot_scene : PackedScene

@export_group("Hotbar Settings")
## The amount of slots in the hotbar. Set this to the same amount as InventoryComponent's slot_amount for all slots to be hotbar slots.
@export var hotbar_slot_amount : int
## The GridContainer which will be used for spacing of the hotbar slots. 
@export var hotbar_container_scene : PackedScene
## The position at where the hotbar_container_scene will be moved to after being instantiated.
@export var hotbar_container_position : Vector2

@export_group("Inventory Settings")
## The GridContainer which will be used for spacing and showing/hiding of the inventory slots.
@export var inventory_container_scene : PackedScene
## The position at where the inventory_container_scene will be moved to after being instantiated.
@export var inventory_container_position : Vector2
## The amount of columns the inventory GridContainer should have.
@export var inventory_container_columns : int

## The InventoryComponent node of the entity.
@onready var inventory_component_node : InventoryComponent = get_parent().inventory_component
## The InventoryUseComponent of the entity.
@onready var inventory_use_component_node : InventoryUseComponent = get_parent().inventory_use_component

var inventory_container_visible : bool
var hotbar_container_node : Control
var inventory_control_node : Control
## The current quick equip mode (right hand or left hand)
var quick_equip_mode : String = "left"
## The current quick equip mode (primary or secondary)
var quick_use_mode : String = "primary"
#------------------------------------------------------------------#
#--------------------Inventory GUI Customization-------------------#
#------------------------------------------------------------------#

# --------------inventory_slot_scene:
# Required nodes: 
# 1: a root Control node, can be named anything (this will accept all player input)
# 2: a Label node, named AmountDisplay (this will display the amount of items in the slot)
# 3: a TextureRect node, named ItemSprite (this will display the sprite of the item)


# --------------hotbar_container:
# Required nodes: 
# 1: a root Control node, named hotbar_control (will be used for hiding the hotbar)
# 2: a GridContainer node, named HotbarGridContainer  (this will put the InventorySlotScenes in a organized grid)

# --------------inventory_container:
# Required nodes: 
# 1: a root Control node, named inventory_control(will be used for hiding the inventory)
# 2: a GridContainer node, named InventoryGridContainer  (this will put the InventorySlotScenes in a organized grid)

func _ready():
	generate_display_slots()

func generate_display_slots() -> void:
	if inventory_component_node.slot_amount > 0 and slot_scene_parent != null:
		var inventory_container_child_index : int
		var inventory_control : Control
		var inventory_container : GridContainer
		var hotbar_slots_left : int = hotbar_slot_amount
		var hotbar_slots_generated : bool
		var hotbar_control : Control
		var hotbar_container : GridContainer
		if inventory_container_scene != null and inventory_slot_scene != null:
			slot_scene_parent.add_child(inventory_container_scene.instantiate())
			inventory_control = slot_scene_parent.get_node("InventoryControl")
			inventory_container = inventory_control.get_node("InventoryGridContainer")
			inventory_control.hide()
			inventory_container.columns = inventory_container_columns
			inventory_control.position = inventory_container_position
			# print("Instanced inventory_container as ", inventory_container, " . This inventory_container has ", inventory_container.columns, " columns and is at position ", inventory_container_position)
		else:
			print("Inventory slots will not be generated due to invalid settings.")
		# print("Hotbar slot generation started. Generating ", hotbar_slot_amount, " ", inventory_slot_scene, " with ", hotbar_container_scene, " as the container scene.")
		if hotbar_container_scene != null and hotbar_container_scene != null:
			slot_scene_parent.add_child(hotbar_container_scene.instantiate())
			hotbar_control = slot_scene_parent.get_node("HotbarControl")
			hotbar_container = hotbar_control.get_node("HotbarGridContainer")
			hotbar_container.columns = hotbar_slot_amount
			hotbar_control.position = hotbar_container_position
			# print("Instanced hotbar_container as ", hotbar_container, " . This hotbar_container has ", hotbar_container.columns, " columns and is at position ", hotbar_container_position)
		else:
			print("Hotbar slots will not be generated due to invalid settings.")
		for slot_resource in inventory_component_node.slot_resources_array:
			if hotbar_slots_left > 0 and hotbar_control != null:
				hotbar_container.add_child(inventory_slot_scene.instantiate())
				var added_slot_scene = hotbar_container.get_child(hotbar_slot_amount - hotbar_slots_left)
				added_slot_scene.linked_slot_resource = slot_resource
				hotbar_slots_left= hotbar_slots_left- 1
				added_slot_scene.hotbar_slot = true
	#			# print("Linked ", added_slot_scene, " to ", added_slot_scene.linked_slot_resource, ", hotbar slots left: ", hotbar_slots_left)
			if hotbar_slots_generated == true and inventory_control != null:
				inventory_container.add_child(inventory_slot_scene.instantiate())
				var added_slot_scene = inventory_container.get_child(inventory_container_child_index)
				added_slot_scene.linked_slot_resource = slot_resource
				inventory_container_child_index = inventory_container_child_index + 1
	#			# print("Linked ", added_slot_scene, " to ", added_slot_scene.linked_slot_resource, ", inventory_container_child_index: ", inventory_container_child_index)
			if hotbar_slots_left== 0 and hotbar_slots_generated == false:
				if hotbar_control != null:
					display_slots_array = hotbar_container.get_children()
				# print("Generation of hotbar slots finished. Generated ", display_slots_array.size(), " slots.")
				hotbar_slots_generated = true
				# print("Inventory slot generation started. Generating remaining ", inventory_component_node.slot_amount - display_slots_array.size(), " slots with the inventory_container from ", inventory_container_scene)
		if inventory_control != null:
			display_slots_array.append_array(inventory_container.get_children())
		# print("Finished generation of Inventory GUI for ", self, ". Generated ", display_slots_array.size(), " slots.")
		# print("DisplaySlotArray: ", display_slots_array)
		inventory_control_node = inventory_control
		hotbar_container_node = hotbar_container
	else:
		print("Required settings for inventory slot generation not specified, generation canceled.")



func _unhandled_key_input(event):
	print(event.as_text())
	if event.is_action_pressed("toggle_inventory"):
		if inventory_container_visible == false:
			inventory_control_node.show()
			inventory_container_visible = true
		elif inventory_container_visible == true:
			inventory_control_node.hide()
			inventory_container_visible = false
	if event.is_action_pressed("toggle_quick_equip_mode") and quick_equip_mode == "left":
		quick_equip_mode = "right"
	elif event.is_action_pressed("toggle_quick_equip_mode") and quick_equip_mode == "right":
		quick_equip_mode = "left"
	if event.is_action_pressed("activate_equipped_item_ability"):
		var equipped_items : Dictionary = inventory_use_component_node.find_two_hand_equipped_items()
		# print(equipped_items)
		if get_parent().current_hand == "left" and equipped_items["equipped_left"] != null:
			# print("left")
			inventory_use_component_node.use_item(equipped_items["equipped_left"], "primary")
		elif get_parent().current_hand == "right" and equipped_items["equipped_right"] != null:
			# print("right")
			inventory_use_component_node.use_item(equipped_items["equipped_right"], "secondary")
## big mess of input reactions
	if event.is_action_pressed("hotbar_slot_1"):
		var hotbar_slot := display_slots_array[0]
		if hotbar_slot.linked_slot_resource.item_resource != null:
			if hotbar_slot.linked_slot_resource.item_resource.find_components(["equip"]) != []:
				if inventory_use_component_node.two_hand_mode == true:
					if quick_equip_mode == "left":
						inventory_use_component_node.equip_item(hotbar_slot.linked_slot_resource, "left")
					elif quick_equip_mode == "right":
						inventory_use_component_node.equip_item(hotbar_slot.linked_slot_resource, "right")
				elif inventory_use_component_node.two_hand_mode == false:
					inventory_use_component_node.equip_item(hotbar_slot.linked_slot_resource)
			elif hotbar_slot.linked_slot_resource.item_resource.find_components(["use"]) != []:
				if quick_equip_mode == "left":
					inventory_use_component_node.use_item(hotbar_slot.linked_slot_resource, "primary")
				elif quick_equip_mode == "right":
					inventory_use_component_node.use_item(hotbar_slot.linked_slot_resource, "secondary")
	elif event.is_action_pressed("hotbar_slot_2"):
		var hotbar_slot := display_slots_array[1]
		if hotbar_slot.linked_slot_resource.item_resource != null:
			if hotbar_slot.linked_slot_resource.item_resource.find_components(["equip"]) != []:
				if inventory_use_component_node.two_hand_mode == true:
					if quick_equip_mode == "left":
						inventory_use_component_node.equip_item(hotbar_slot.linked_slot_resource, "left")
					elif quick_equip_mode == "right":
						inventory_use_component_node.equip_item(hotbar_slot.linked_slot_resource, "right")
				elif inventory_use_component_node.two_hand_mode == false:
					inventory_use_component_node.equip_item(hotbar_slot.linked_slot_resource)
			elif hotbar_slot.linked_slot_resource.item_resource.find_components(["use"]) != []:
				if quick_equip_mode == "left":
					inventory_use_component_node.use_item(hotbar_slot.linked_slot_resource, "primary")
				elif quick_equip_mode == "right":
					inventory_use_component_node.use_item(hotbar_slot.linked_slot_resource, "secondary")
	elif event.is_action_pressed("hotbar_slot_3"):
		var hotbar_slot := display_slots_array[2]
		if hotbar_slot.linked_slot_resource.item_resource != null:
			if hotbar_slot.linked_slot_resource.item_resource.find_components(["equip"]) != []:
				if inventory_use_component_node.two_hand_mode == true:
					if quick_equip_mode == "left":
						inventory_use_component_node.equip_item(hotbar_slot.linked_slot_resource, "left")
					elif quick_equip_mode == "right":
						inventory_use_component_node.equip_item(hotbar_slot.linked_slot_resource, "right")
				elif inventory_use_component_node.two_hand_mode == false:
					inventory_use_component_node.equip_item(hotbar_slot.linked_slot_resource)
			elif hotbar_slot.linked_slot_resource.item_resource.find_components(["use"]) != []:
				if quick_equip_mode == "left":
					inventory_use_component_node.use_item(hotbar_slot.linked_slot_resource, "primary")
				elif quick_equip_mode == "right":
					inventory_use_component_node.use_item(hotbar_slot.linked_slot_resource, "secondary")
	elif event.is_action_pressed("hotbar_slot_4"):
		var hotbar_slot := display_slots_array[3]
		if hotbar_slot.linked_slot_resource.item_resource != null:
			if hotbar_slot.linked_slot_resource.item_resource.find_components(["equip"]) != []:
				if inventory_use_component_node.two_hand_mode == true:
					if quick_equip_mode == "left":
						inventory_use_component_node.equip_item(hotbar_slot.linked_slot_resource, "left")
					elif quick_equip_mode == "right":
						inventory_use_component_node.equip_item(hotbar_slot.linked_slot_resource, "right")
				elif inventory_use_component_node.two_hand_mode == false:
					inventory_use_component_node.equip_item(hotbar_slot.linked_slot_resource)
			elif hotbar_slot.linked_slot_resource.item_resource.find_components(["use"]) != []:
				if quick_equip_mode == "left":
					inventory_use_component_node.use_item(hotbar_slot.linked_slot_resource, "primary")
				elif quick_equip_mode == "right":
					inventory_use_component_node.use_item(hotbar_slot.linked_slot_resource, "secondary")
	elif event.is_action_pressed("hotbar_slot_5"):
		var hotbar_slot := display_slots_array[4]
		if hotbar_slot.linked_slot_resource.item_resource != null:
			if hotbar_slot.linked_slot_resource.item_resource.find_components(["equip"]) != []:
				if inventory_use_component_node.two_hand_mode == true:
					if quick_equip_mode == "left":
						inventory_use_component_node.equip_item(hotbar_slot.linked_slot_resource, "left")
					elif quick_equip_mode == "right":
						inventory_use_component_node.equip_item(hotbar_slot.linked_slot_resource, "right")
				elif inventory_use_component_node.two_hand_mode == false:
					inventory_use_component_node.equip_item(hotbar_slot.linked_slot_resource)
			elif hotbar_slot.linked_slot_resource.item_resource.find_components(["use"]) != []:
				if quick_equip_mode == "left":
					inventory_use_component_node.use_item(hotbar_slot.linked_slot_resource, "primary")
				elif quick_equip_mode == "right":
					inventory_use_component_node.use_item(hotbar_slot.linked_slot_resource, "secondary")
	elif event.is_action_pressed("hotbar_slot_6"):
		var hotbar_slot := display_slots_array[5]
		if hotbar_slot.linked_slot_resource.item_resource != null:
			if hotbar_slot.linked_slot_resource.item_resource.find_components(["equip"]) != []:
				if inventory_use_component_node.two_hand_mode == true:
					if quick_equip_mode == "left":
						inventory_use_component_node.equip_item(hotbar_slot.linked_slot_resource, "left")
					elif quick_equip_mode == "right":
						inventory_use_component_node.equip_item(hotbar_slot.linked_slot_resource, "right")
				elif inventory_use_component_node.two_hand_mode == false:
					inventory_use_component_node.equip_item(hotbar_slot.linked_slot_resource)
			elif hotbar_slot.linked_slot_resource.item_resource.find_components(["use"]) != []:
				if quick_equip_mode == "left":
					inventory_use_component_node.use_item(hotbar_slot.linked_slot_resource, "primary")
				elif quick_equip_mode == "right":
					inventory_use_component_node.use_item(hotbar_slot.linked_slot_resource, "secondary")
	elif event.is_action_pressed("hotbar_slot_7"):
		var hotbar_slot := display_slots_array[6]
		if hotbar_slot.linked_slot_resource.item_resource != null:
			if hotbar_slot.linked_slot_resource.item_resource.find_components(["equip"]) != []:
				if inventory_use_component_node.two_hand_mode == true:
					if quick_equip_mode == "left":
						inventory_use_component_node.equip_item(hotbar_slot.linked_slot_resource, "left")
					elif quick_equip_mode == "right":
						inventory_use_component_node.equip_item(hotbar_slot.linked_slot_resource, "right")
				elif inventory_use_component_node.two_hand_mode == false:
					inventory_use_component_node.equip_item(hotbar_slot.linked_slot_resource)
			elif hotbar_slot.linked_slot_resource.item_resource.find_components(["use"]) != []:
				if quick_equip_mode == "left":
					inventory_use_component_node.use_item(hotbar_slot.linked_slot_resource, "primary")
				elif quick_equip_mode == "right":
					inventory_use_component_node.use_item(hotbar_slot.linked_slot_resource, "secondary")
	elif event.is_action_pressed("hotbar_slot_8"):
		var hotbar_slot := display_slots_array[7]
		if hotbar_slot.linked_slot_resource.item_resource != null:
			if hotbar_slot.linked_slot_resource.item_resource.find_components(["equip"]) != []:
				if inventory_use_component_node.two_hand_mode == true:
					if quick_equip_mode == "left":
						inventory_use_component_node.equip_item(hotbar_slot.linked_slot_resource, "left")
					elif quick_equip_mode == "right":
						inventory_use_component_node.equip_item(hotbar_slot.linked_slot_resource, "right")
				elif inventory_use_component_node.two_hand_mode == false:
					inventory_use_component_node.equip_item(hotbar_slot.linked_slot_resource)
			elif hotbar_slot.linked_slot_resource.item_resource.find_components(["use"]) != []:
				if quick_equip_mode == "left":
					inventory_use_component_node.use_item(hotbar_slot.linked_slot_resource, "primary")
				elif quick_equip_mode == "right":
					inventory_use_component_node.use_item(hotbar_slot.linked_slot_resource, "secondary")
	elif event.is_action_pressed("hotbar_slot_9"):
		var hotbar_slot := display_slots_array[8]
		if hotbar_slot.linked_slot_resource.item_resource != null:
			if hotbar_slot.linked_slot_resource.item_resource.find_components(["equip"]) != []:
				if inventory_use_component_node.two_hand_mode == true:
					if quick_equip_mode == "left":
						inventory_use_component_node.equip_item(hotbar_slot.linked_slot_resource, "left")
					elif quick_equip_mode == "right":
						inventory_use_component_node.equip_item(hotbar_slot.linked_slot_resource, "right")
				elif inventory_use_component_node.two_hand_mode == false:
					inventory_use_component_node.equip_item(hotbar_slot.linked_slot_resource)
			elif hotbar_slot.linked_slot_resource.item_resource.find_components(["use"]) != []:
				if quick_equip_mode == "left":
					inventory_use_component_node.use_item(hotbar_slot.linked_slot_resource, "primary")
				elif quick_equip_mode == "right":
					inventory_use_component_node.use_item(hotbar_slot.linked_slot_resource, "secondary")
	elif event.is_action_pressed("hotbar_slot_10"):
		var hotbar_slot := display_slots_array[9]
		if hotbar_slot.linked_slot_resource.item_resource != null:
			if hotbar_slot.linked_slot_resource.item_resource.find_components(["equip"]) != []:
				if inventory_use_component_node.two_hand_mode == true:
					if quick_equip_mode == "left":
						inventory_use_component_node.equip_item(hotbar_slot.linked_slot_resource, "left")
					elif quick_equip_mode == "right":
						inventory_use_component_node.equip_item(hotbar_slot.linked_slot_resource, "right")
				elif inventory_use_component_node.two_hand_mode == false:
					inventory_use_component_node.equip_item(hotbar_slot.linked_slot_resource)
			elif hotbar_slot.linked_slot_resource.item_resource.find_components(["use"]) != []:
				if quick_equip_mode == "left":
					inventory_use_component_node.use_item(hotbar_slot.linked_slot_resource, "primary")
				elif quick_equip_mode == "right":
					inventory_use_component_node.use_item(hotbar_slot.linked_slot_resource, "secondary")
	elif event.is_action_pressed("hotbar_slot_11"):
		var hotbar_slot := display_slots_array[10]
		if hotbar_slot.linked_slot_resource.item_resource != null:
			if hotbar_slot.linked_slot_resource.item_resource.find_components(["equip"]) != []:
				if inventory_use_component_node.two_hand_mode == true:
					if quick_equip_mode == "left":
						inventory_use_component_node.equip_item(hotbar_slot.linked_slot_resource, "left")
					elif quick_equip_mode == "right":
						inventory_use_component_node.equip_item(hotbar_slot.linked_slot_resource, "right")
				elif inventory_use_component_node.two_hand_mode == false:
					inventory_use_component_node.equip_item(hotbar_slot.linked_slot_resource)
			elif hotbar_slot.linked_slot_resource.item_resource.find_components(["use"]) != []:
				if quick_equip_mode == "left":
					inventory_use_component_node.use_item(hotbar_slot.linked_slot_resource, "primary")
				elif quick_equip_mode == "right":
					inventory_use_component_node.use_item(hotbar_slot.linked_slot_resource, "secondary")
