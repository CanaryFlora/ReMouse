extends Panel
# A script that manages a specific slot's GUI.

signal slot_click(SlotNode : Control, SlotResource : InventorySlotResource, InputType : String)

var LinkedSlotResource : InventorySlotResource
var HotbarSlot : bool

@onready var AmountDisplay : Node = get_node("AmountDisplay")
@onready var ItemSprite : Node = get_node("ItemSprite")

# The textures this slot should use when it is selected by the player.
@export var RightEquippedTheme : Theme
@export var LeftEquippedTheme : Theme
@export var BaseTheme : Theme

func _process(delta):
	if LinkedSlotResource.ItemResource != null:
		ItemSprite.texture = LinkedSlotResource.ItemResource.ItemTexture
		AmountDisplay.text = str(LinkedSlotResource.ItemAmount)
		if LinkedSlotResource.ItemEquippedRight == true:
			self.theme = RightEquippedTheme
		elif LinkedSlotResource.ItemEquippedLeft == true:
			self.theme = LeftEquippedTheme
		elif LinkedSlotResource.ItemEquippedRight == false and LinkedSlotResource.ItemEquippedLeft == false:
			self.theme = BaseTheme
	elif LinkedSlotResource.ItemResource == null:
		ItemSprite.texture = null
		AmountDisplay.text = str(0)


func _on_gui_input(event):
	if event.is_action_pressed("LeftClick") == true:
		emit_signal("slot_click", self, LinkedSlotResource, "LMB")
#		print("thing")
	elif event.is_action_pressed("RightClick") == true:
		emit_signal("slot_click", self, LinkedSlotResource, "RMB")
#		print("thing")
