extends Control
# A script that manages a specific slot's GUI.

# The textures this slot should use when it is selected by the player.
const right_equipped_theme : Theme = preload("res://inventory/themes/right_equipped_theme.tres")
const left_equipped_theme : Theme = preload("res://inventory/themes/left_equipped_theme.tres")
const base_theme : Theme = preload("res://inventory/themes/base_slot_theme.tres")
const two_hand_equipped_theme : Theme = preload("res://inventory/themes/two_hand_equipped_theme.tres")
const ITEM_TOOLTIP_SCENE : PackedScene = preload("res://inventory/item_tooltip.tscn")

## If this GUI inventory slot is a Panel.
@export var is_panel : bool = true


## The InventorySlotResource this GUI inventory slot will display the data of.
var linked_slot_resource : InventorySlotResource
## If this GUI inventory slot is a hotbar slot.
var hotbar_slot : bool


@onready var amount_display : Node = get_node("AmountDisplay")
@onready var item_sprite : Node = get_node("ItemSprite")


func _process(delta):
	if linked_slot_resource.item_resource != null:
		item_sprite.texture = linked_slot_resource.item_resource.item_texture
		amount_display.text = str(linked_slot_resource.item_amount)
		tooltip_text = linked_slot_resource.item_resource.item_name + "||itemsplit||" + linked_slot_resource.item_resource.description + "||itemsplit||" + linked_slot_resource.item_resource.details
		if is_panel == true:
			if linked_slot_resource.item_resource.equip_component != null:
				if linked_slot_resource.item_resource.equip_component.item_equipped_left == true and linked_slot_resource.item_resource.equip_component.item_equipped_right == true:
					self.theme = two_hand_equipped_theme
				elif linked_slot_resource.item_resource.equip_component.item_equipped_left == true:
					self.theme = left_equipped_theme
				elif linked_slot_resource.item_resource.equip_component.item_equipped_right == true:
					self.theme = right_equipped_theme
				elif linked_slot_resource.item_resource.equip_component.item_equipped_left == false and linked_slot_resource.item_resource.equip_component.item_equipped_right == false:
					self.theme = base_theme
	elif linked_slot_resource.item_resource == null:
		item_sprite.texture = null
		amount_display.text = str(0)
#	if amount_display.visible and linked_slot_resource.item_amount == 0:
#		amount_display.hide()
#	elif amount_display.hidden and linked_slot_resource.item_amount > 0:
#		amount_display.show()


func _make_custom_tooltip(for_text):
	var text_array : PackedStringArray = for_text.split("||itemsplit||")
	var item_name : StringName = text_array[0]
	var item_description : String = text_array[1]
	var item_details : String = text_array[2]
	var item_tooltip : Control = ITEM_TOOLTIP_SCENE.instantiate()
	item_tooltip.get_node("MarginContainer/EffectTooltip/Title").text = "[font_size=24][color=e6c552]%s[/color][/font_size]" % item_name
	item_tooltip.get_node("MarginContainer/EffectTooltip/Description").text = "[font_size=18][color=ebebeb]%s[/color][/font_size]" % item_description
	item_tooltip.get_node("MarginContainer/EffectTooltip/Details").text ="[font_size=14][color=889393]%s[/color][/font_size]" % item_details
	return item_tooltip

func _get_drag_data(at_position):
	if linked_slot_resource.item_resource != null:
		var drag_preview = TextureRect.new()
		drag_preview.z_index = 100
		drag_preview.size = Vector2(40, 40)
		drag_preview.texture = linked_slot_resource.item_resource.item_texture
		drag_preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		drag_preview.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
		set_drag_preview(drag_preview)
		return [self, linked_slot_resource]


func _can_drop_data(at_position, data):
	return typeof(data) == TYPE_ARRAY


func _drop_data(at_position, data):
	data[0].linked_slot_resource = linked_slot_resource
	linked_slot_resource = data[1]
	if hotbar_slot == false:
		linked_slot_resource.item_resource.equip_component.item_equipped_left = false
		linked_slot_resource.item_resource.equip_component.item_equipped_right = false
