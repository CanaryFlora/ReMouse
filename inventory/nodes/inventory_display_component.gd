extends InventoryComponent
## A class for creating a GUI to interact with an inventory.
class_name InventoryDisplayComponent


## An array of this component's InventorySlotPanels.
var display_slots_array : Array[Node]
var _dragged_slot : InventorySlotPanel
var _mouse_over_slot : InventorySlotPanel
var _right_click_down : bool

## The node that InventorySlotScenes will be added as a child of.
@export var slot_scene_parent : Node
## The scene which will be used as the GUI inventory slot. See the code for InventoryDisplayComponent for guidelines on how to create a custom inventory scene.
@export var inventory_slot_scene : PackedScene
## If this component will support equipping items and require an InventoryEquipComponent to function.
@export var equip_allowed : bool
## If this component will support using items and require an InventoryUseComponent to function.
@export var use_allowed : bool

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
## If the inventory should turn off right hand equip mode after an item is equipped.
@export var toggle_right_hand_equip_mode_on_equip : bool
## How much time must pass before an item gets unstacked into a slot while the player is unstacking items.
@export var unstack_rate : float

## The InventoryUseComponent of the entity.
@onready var inventory_use_component_node : InventoryUseComponent = get_parent().inventory_use_component
## The InventoryEquipComponent of the entity.
@onready var inventory_equip_component_node : InventoryEquipComponent = get_parent().inventory_equip_component


var inventory_container_visible : bool
var hotbar_container_node : Control
var inventory_control_node : Control
var unstack_timer : Timer
## If the right hand equip mode is on.
var right_hand_equip_mode : bool


const UNSTACK_TIMER_SCENE : PackedScene = preload("res://inventory/unstack_timer.tscn")


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


func _physics_process(delta):
	# check if unstacking requirements are satisfied, if yes and unstack timer isnt running, start unstack timer 
	# if not, stop unstack timer if its running
	# also check some other misc stuff so we don't get an error
	if inventory_container_visible and _dragged_slot != null and _mouse_over_slot != null and _right_click_down:
		if _dragged_slot.linked_slot_resource.item_resource != null:
			if (
				unstack_timer.is_stopped()
				):
				# emit timeout so when the player clicks once, one item is stacked and they dont have to wait
				if _mouse_over_slot.linked_slot_resource.item_resource != null:
					if _mouse_over_slot.linked_slot_resource.item_resource.item_name != _dragged_slot.linked_slot_resource.item_resource.item_name:
						var unstack_drag_preview : TextureRect = _dragged_slot.make_drag_preview()
						unstack_drag_preview.scale = Vector2(0.5, 0.5)
						_dragged_slot.set_drag_preview(unstack_drag_preview)
				unstack_timer.emit_signal("timeout")
				## give timer a small delay so player doesn't accidentally stack more items
				unstack_timer.wait_time += 0.1
				unstack_timer.timeout.connect(_reset_timer_delay)
				unstack_timer.start()
	if !_right_click_down:
		if !unstack_timer.is_stopped():
			if _dragged_slot != null:
				_dragged_slot.set_drag_preview(_dragged_slot.make_drag_preview())
			unstack_timer.stop()


func _ready():
	super()
	generate_display_slots()
	# connect signals for unstacking
	for display_slot : InventorySlotPanel in display_slots_array:
		display_slot.inventory_display_component = self
		display_slot.dragged_slot.connect(func(slot_panel : InventorySlotPanel):
			_dragged_slot = slot_panel
			)
		display_slot.dropped_slot.connect(func(slot_panel : InventorySlotPanel):
			_dragged_slot = null
			)
		display_slot.mouse_entered.connect(func():
			_mouse_over_slot = display_slot
			# emit timeout when mouse moved to a new slot
			if inventory_container_visible and _dragged_slot != null and _right_click_down:
				unstack_timer.emit_signal("timeout")
				# reset timer
				unstack_timer.stop()
				unstack_timer.start()
			)
		display_slot.mouse_exited.connect(func():
			_mouse_over_slot = null
			)
	# instantiate unstack timer
	unstack_timer = UNSTACK_TIMER_SCENE.instantiate()
	unstack_timer.wait_time = unstack_rate
	unstack_timer.timeout.connect(func():
		# unstack item if possible
		if _mouse_over_slot != null and _dragged_slot != null:
			if _dragged_slot.linked_slot_resource.item_resource != null and _dragged_slot.linked_slot_resource.item_amount > 0:
				var prev_item_resource : ItemResource = _dragged_slot.linked_slot_resource.item_resource
				remove_item(_dragged_slot.linked_slot_resource.item_resource.item_name, 1, _dragged_slot.linked_slot_resource)
				add_item(prev_item_resource.item_name, 1, _mouse_over_slot.linked_slot_resource)
			elif _dragged_slot.linked_slot_resource.item_amount <= 0:
				# if dragged slot does not have any more items in it, force cancel drag
				var cancel_input : InputEventMouseButton = InputEventMouseButton.new()
				cancel_input.pressed = false
				cancel_input.button_index = 1
				get_viewport().push_input(cancel_input)
				_right_click_down = false
				_dragged_slot = null
		)
	self.add_child(unstack_timer)

## Instantiates and sets up this component's InventorySlotPanels.
func generate_display_slots() -> void:
	if slot_amount > 0 and slot_scene_parent != null:
		var inventory_container_child_index : int
		var inventory_control : Control
		var inventory_container : GridContainer
		var hotbar_slots_left : int = hotbar_slot_amount
		var hotbar_slots_generated : bool
		var hotbar_control : Control
		var hotbar_container : GridContainer
		if inventory_container_scene != null and inventory_slot_scene != null and slot_scene_parent != null:
			slot_scene_parent.add_child(inventory_container_scene.instantiate())
			inventory_control = slot_scene_parent.get_node("InventoryControl")
			inventory_container = inventory_control.get_node("InventoryGridContainer")
			inventory_control.hide()
			inventory_container.columns = inventory_container_columns
			inventory_control.position = inventory_container_position
			# print("Instanced inventory_container as ", inventory_container, " . This inventory_container has ", inventory_container.columns, " columns and is at position ", inventory_container_position)
		else:
			push_error("Inventory slots will not be generated due to invalid settings.")
		# print("Hotbar slot generation started. Generating ", hotbar_slot_amount, " ", inventory_slot_scene, " with ", hotbar_container_scene, " as the container scene.")
		if hotbar_container_scene != null and hotbar_container_scene != null and slot_scene_parent != null:
			slot_scene_parent.add_child(hotbar_container_scene.instantiate())
			hotbar_control = slot_scene_parent.get_node("HotbarControl")
			hotbar_container = hotbar_control.get_node("HotbarGridContainer")
			hotbar_container.columns = hotbar_slot_amount
			hotbar_control.position = hotbar_container_position
			# print("Instanced hotbar_container as ", hotbar_container, " . This hotbar_container has ", hotbar_container.columns, " columns and is at position ", hotbar_container_position)
		else:
			push_error("Hotbar slots will not be generated due to invalid settings.")
		for slot_resource in slot_resources_array:
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
	## inventory toggle
	if event.is_action_pressed("toggle_inventory"):
		if inventory_container_visible == false:
			inventory_control_node.show()
			inventory_container_visible = true
		elif inventory_container_visible == true:
			inventory_control_node.hide()
			inventory_container_visible = false
	## right hand equip mode
	if event.is_action_pressed("right_hand_equip_mode") and !right_hand_equip_mode:
		right_hand_equip_mode = true
	elif event.is_action_pressed("right_hand_equip_mode") and right_hand_equip_mode:
		right_hand_equip_mode = false
	## activate item ability
	if use_allowed:
		if event.is_action_pressed("use_left_hand_secondary"):
			inventory_use_component_node.use_item(inventory_equip_component_node.left_hand_equipped_item, 
			inventory_use_component_node.UseType.SECONDARY)
		elif event.is_action_pressed("use_right_hand_secondary"):
			inventory_use_component_node.use_item(inventory_equip_component_node.right_hand_equipped_item, 
			inventory_use_component_node.UseType.SECONDARY)
	## hotbar equip hotkeys and using the primary abilty of items in the hotbar
	if equip_allowed:
		if event.pressed and !event.echo:
			for i in range(11):
				if event.is_action_pressed("hotbar_slot_" + str(i + 1)):
					var pressed_slot : InventorySlotResource = display_slots_array[i].linked_slot_resource
					if pressed_slot.item_resource != null:
						## hotbar equip hotkey logic
						if pressed_slot.item_resource.equip_component != null:
							if (
							pressed_slot.item_resource.equip_component is TwoHandComponent 
							and pressed_slot.item_resource.equip_component.item_equipped_left 
							and pressed_slot.item_resource.equip_component.item_equipped_left
							and pressed_slot.item_resource.equip_component.two_hand_only
							):
								inventory_equip_component_node.unequip_item(pressed_slot, inventory_equip_component_node.EquipType.TWO_HAND)
							elif (
								pressed_slot.item_resource.equip_component.item_equipped_left
								and !pressed_slot.item_resource.equip_component is TwoHandComponent
								or pressed_slot.item_resource.equip_component is TwoHandComponent
								and pressed_slot.item_resource.equip_component.item_equipped_left
								and !right_hand_equip_mode
								):
								inventory_equip_component_node.unequip_item(pressed_slot, inventory_equip_component_node.EquipType.LEFT_HAND)
							elif (
								pressed_slot.item_resource.equip_component.item_equipped_right
								and !pressed_slot.item_resource.equip_component is TwoHandComponent
								or pressed_slot.item_resource.equip_component is TwoHandComponent
								and pressed_slot.item_resource.equip_component.item_equipped_right
								and right_hand_equip_mode
								):
								inventory_equip_component_node.unequip_item(pressed_slot, inventory_equip_component_node.EquipType.RIGHT_HAND)
							else:
								if (
									pressed_slot.item_resource.equip_component is TwoHandComponent 
									and pressed_slot.item_resource.equip_component.two_hand_only
									):
										inventory_equip_component_node.equip_item(pressed_slot, inventory_equip_component_node.EquipType.TWO_HAND)
								elif right_hand_equip_mode:
									inventory_equip_component_node.equip_item(pressed_slot, inventory_equip_component_node.EquipType.RIGHT_HAND, !(
										pressed_slot.item_resource.equip_component is TwoHandComponent 
										and pressed_slot.item_resource.equip_component.two_hand_only))
								else:
									inventory_equip_component_node.equip_item(pressed_slot, inventory_equip_component_node.EquipType.LEFT_HAND, !(
										pressed_slot.item_resource.equip_component is TwoHandComponent 
										and pressed_slot.item_resource.equip_component.two_hand_only))
						elif pressed_slot.item_resource.use_component != null and use_allowed:
							inventory_use_component_node.use_item(pressed_slot, inventory_use_component_node.UseType.PRIMARY)


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == 2:
			match event.pressed:
				true:
					_right_click_down = true
				false:
					_right_click_down = false


# this has to be a standalone method because otherwise it's impossible to disconnect
func _reset_timer_delay():
	unstack_timer.wait_time -= 0.1
	unstack_timer.disconnect("timeout", _reset_timer_delay)
