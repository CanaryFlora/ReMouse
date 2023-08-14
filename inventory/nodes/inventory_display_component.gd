extends Node
## A class for creating a GUI to interact with an inventory.
class_name InventoryDisplayComponent

var DisplaySlotsArray : Array
@onready var Entity : Node = self.get_parent()

## The InventoryComponent node of the entity.
@export var InventoryComponentNode : InventoryComponent
## The node that InventorySlotScenes will be added as a child of.
@export var SlotSceneParent : Node


@export_group("Hotbar Settings")
## The amount of slots in the hotbar. Set this to the same amount as InventoryComponent's SlotAmount for all slots to be hotbar slots.
@export var HotbarSlotAmount : int
## The GridContainer which will be used for spacing of the hotbar slots. 
@export var HotbarContainerScene : PackedScene
## The position at where the HotbarContainerScene will be moved to after being instantiated.
@export var HotbarContainerPosition : Vector2

@export_group("Inventory Settings")
## The GridContainer which will be used for spacing and showing/hiding of the inventory slots.
@export var InventoryContainerScene : PackedScene
## The position at where the InventoryContainerScene will be moved to after being instantiated.
@export var InventoryContainerPosition : Vector2
## The amount of columns the inventory GridContainer should have.
@export var InventoryContainerColumns : int

## The scene which will be used as the GUI inventory slot. See the code for InventoryDisplayComponent for guidelines on how to create a custom inventory scene.
@export var InventorySlotScene : PackedScene


#------------------------------------------------------------------#
#--------------------Inventory GUI Customization-------------------#
#------------------------------------------------------------------#

# --------------InventorySlotScene:
# An InventorySlotScene has 3 required nodes. Any other nodes will be ignored.
# Required nodes: 
# 1: a root Control node, can be named anything (this will accept all player input)
# 2: a Label node, named AmountDisplay (this will display the amount of items in the slot)
# 3: a TextureRect node, named ItemSprite (this will display the sprite of the item)


# --------------HotbarContainer:
# A HotbarContainer has 2 required nodes. Any other nodes will be ignored.
# Required nodes: 
# 1: a root Control node, can be named anything (will be useful for hiding the hotbar)
# 2: a GridContainer node, named HotbarGridContainer  (this will put the InventorySlotScenes in a organized grid)

# --------------InventoryContainer:
# An InventoryContainer has 2 required nodes. Any other nodes will be ignored.
# Required nodes: 
# 1: a root Control node, can be named anything (will be useful for hiding the inventory)
# 2: a GridContainer node, named InventoryGridContainer  (this will put the InventorySlotScenes in a organized grid)

func _ready():
	generate_display_slots(HotbarContainerScene, InventorySlotScene, HotbarSlotAmount)
	pass

func generate_display_slots(ContainerScene : PackedScene, SlotScene : PackedScene, HotbarSlots : int) -> void:
	print("Hotbar slot generation started. Generating ", HotbarSlots, " ", SlotScene, " with ", ContainerScene, " as the container scene.")
	var HotbarSlotsLeft : int = HotbarSlots
	var HotbarSlotsGenerated : bool
	SlotSceneParent.add_child(ContainerScene.instantiate())
	var HotbarControl : Control = SlotSceneParent.get_child(0)
	var HotbarContainer : GridContainer = SlotSceneParent.get_child(0).get_node("HotbarGridContainer")
	HotbarContainer.columns = HotbarSlots
	HotbarControl.position = HotbarContainerPosition
	print("Instanced HotbarContainer as ", HotbarContainer, " . This HotbarContainer has ", HotbarContainer.columns, " columns and is at position ", HotbarContainerPosition)
	SlotSceneParent.add_child(InventoryContainerScene.instantiate())
	var InventoryContainerChildIndex : int
	var InventoryControl : Control = SlotSceneParent.get_child(1)
	var InventoryContainer : GridContainer = SlotSceneParent.get_child(1).get_node("InventoryGridContainer")
	InventoryContainer.columns = InventoryContainerColumns
	InventoryControl.position = InventoryContainerPosition
	print("Instanced InventoryContainer as ", InventoryContainer, " . This InventoryContainer has ", InventoryContainer.columns, " columns and is at position ", InventoryContainerPosition)
	for SlotResource in InventoryComponentNode.SlotResourcesArray:
		if HotbarSlotsLeft > 0:
			HotbarContainer.add_child(SlotScene.instantiate())
			var AddedSlotScene = HotbarContainer.get_child(HotbarSlots - HotbarSlotsLeft)
			AddedSlotScene.LinkedSlotResource = SlotResource
			HotbarSlotsLeft = HotbarSlotsLeft - 1
			AddedSlotScene.HotbarSlot = true
#			print("Linked ", AddedSlotScene, " to ", AddedSlotScene.LinkedSlotResource, ", hotbar slots left: ", HotbarSlotsLeft)
		if HotbarSlotsGenerated == true:
			InventoryContainer.add_child(SlotScene.instantiate())
			var AddedSlotScene = InventoryContainer.get_child(InventoryContainerChildIndex)
			AddedSlotScene.LinkedSlotResource = SlotResource
			InventoryContainerChildIndex = InventoryContainerChildIndex + 1
#			print("Linked ", AddedSlotScene, " to ", AddedSlotScene.LinkedSlotResource, ", InventoryContainerChildIndex: ", InventoryContainerChildIndex)
		if HotbarSlotsLeft == 0 and HotbarSlotsGenerated == false:
			DisplaySlotsArray = HotbarContainer.get_children()
			print("Generation of hotbar slots finished. Generated ", DisplaySlotsArray.size(), " slots.")
			HotbarSlotsGenerated = true
			print("Inventory slot generation started. Generating remaining ", InventoryComponentNode.SlotAmount - DisplaySlotsArray.size(), " slots with the InventoryContainer from ", InventoryContainerScene)
	DisplaySlotsArray.append_array(InventoryContainer.get_children())
	print("Finished generation of Inventory GUI for ", self, ". Generated ", DisplaySlotsArray.size(), " slots.")
	print("DisplaySlotArray: ", DisplaySlotsArray)
	for DisplaySlot in DisplaySlotsArray:
		DisplaySlot.slot_click.connect(slot_click_handler)
	print("connected")




func slot_click_handler(SlotNode : Control, SlotResource : InventorySlotResource, InputType : String):
	if SlotResource.ItemResource != null:
		if SlotNode.HotbarSlot == true and SlotResource.ItemResource.ItemEquippable == true:
			match InputType:
				"LMB":
					match SlotResource.ItemEquippedLeft:
						# if left clicked on a left equipped slot
						true:
							# unequip slot
							InventoryComponentNode.edit_slot_resource_util(SlotResource, SlotResource.ItemResource, SlotResource.ItemAmount, false, false)
							print("Unequipped SlotResource ", SlotResource)
						# if left clicked on a non left equipped slot
						false:
							match SlotResource.ItemEquippedRight:
								true:
									# make clicked slot the left equipped item, unequip previous left and right
									var PreviousSlotResource : InventorySlotResource = get_parent().EquippedInLeft
									print("Previous SlotResource: ", PreviousSlotResource)
									if PreviousSlotResource != null:
										InventoryComponentNode.edit_slot_resource_util(PreviousSlotResource, PreviousSlotResource.ItemResource, PreviousSlotResource.ItemAmount, false, false)
										get_parent().EquippedInLeft = null
										get_parent().EquippedInRight = null
									get_parent().EquippedInLeft = SlotResource
									InventoryComponentNode.edit_slot_resource_util(SlotResource, SlotResource.ItemResource, SlotResource.ItemAmount, true, false)
									print("Equipped SlotResource", SlotResource)
								false:
									# make clicked slot the left equipped item, unequip previous left
									var PreviousSlotResource : InventorySlotResource = get_parent().EquippedInLeft
									print("Previous SlotResource: ", PreviousSlotResource)
									if PreviousSlotResource != null:
										InventoryComponentNode.edit_slot_resource_util(PreviousSlotResource, PreviousSlotResource.ItemResource, PreviousSlotResource.ItemAmount, false, false)
										get_parent().EquippedInLeft = null
									get_parent().EquippedInLeft = SlotResource
									InventoryComponentNode.edit_slot_resource_util(SlotResource, SlotResource.ItemResource, SlotResource.ItemAmount, true, false)
									print("Equipped SlotResource", SlotResource)
				"RMB":
					match SlotResource.ItemEquippedRight:
						# if right clicked on a right equipped slot
						true:
							# unequip slot
							InventoryComponentNode.edit_slot_resource_util(SlotResource, SlotResource.ItemResource, SlotResource.ItemAmount, false, false)
							print("Unequipped SlotResource ", SlotResource)
						false:
							match SlotResource.ItemEquippedLeft:
								true:
									# make clicked slot the right equipped item, unequip previous right and left
									var PreviousSlotResource : InventorySlotResource = get_parent().EquippedInRight
									if PreviousSlotResource != null:
										InventoryComponentNode.edit_slot_resource_util(PreviousSlotResource, PreviousSlotResource.ItemResource, PreviousSlotResource.ItemAmount, false, false)
										get_parent().EquippedInRight = null
										get_parent().EquippedInLeft = null
									get_parent().EquippedInRight = SlotResource
									InventoryComponentNode.edit_slot_resource_util(SlotResource, SlotResource.ItemResource, SlotResource.ItemAmount, false, true)
									print("Equipped SlotResource", SlotResource)
								false:
									# make clicked slot the right equipped item, unequip previous right
									var PreviousSlotResource : InventorySlotResource = get_parent().EquippedInRight
									if PreviousSlotResource != null:
										InventoryComponentNode.edit_slot_resource_util(PreviousSlotResource, PreviousSlotResource.ItemResource, PreviousSlotResource.ItemAmount, false, false)
										get_parent().EquippedInRight = null
									get_parent().EquippedInRight = SlotResource
									InventoryComponentNode.edit_slot_resource_util(SlotResource, SlotResource.ItemResource, SlotResource.ItemAmount, false, true)
									print("Equipped SlotResource", SlotResource)
