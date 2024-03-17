extends Resource
## A simple class that stores the basic information of an item and its uses in crafting.
class_name ItemResource

## The item's name in-game.
@export var item_name : StringName
## Image which should be used as the texture of the item.
@export var item_texture : CompressedTexture2D
## How much of this item can be in a single stack.
@export var stack_amount : int = 99
@export var item_components : Array[ItemComponent]
@export var item_specific_properties : Dictionary

## Finds a component of this item with the specified name.
func find_components(component_names : Array):
	var found_components_array : Array[ItemComponent]
	for component_name in component_names:
		for item_component in item_components:
			if component_name == item_component.component_name:
				found_components_array.append(item_component)
	return found_components_array
			
