extends RigidBody2D
class_name Entity

var _entered_tree : bool

#@export_group("Entity")
## A list of components for use by the entity. Not all components are required for an entity to function.
var inventory_component : InventoryComponent
var inventory_display_component : InventoryDisplayComponent
var base_player_movement_component : BasePlayerMovementComponent
var inventory_use_component : InventoryUseComponent
var variable_stats_component : EntityVariableStatsComponent
var effect_component : EffectComponent
var effect_display_component : EffectDisplayComponent
var inventory_equip_component : InventoryEquipComponent

##HACK
func _enter_tree():
	if !_entered_tree:
		find_components()
		_entered_tree = true

#
#
func find_components():
	var children : Array = self.get_children()
	#print("thing")
	#print(self.get_children().find(InventoryComponent))
	for child : Node in children:
		if child is InventoryComponent:
			inventory_component = child
		elif child is InventoryDisplayComponent:
			inventory_display_component = child
		elif child is BasePlayerMovementComponent:
			base_player_movement_component = child
		elif child is InventoryUseComponent:
			inventory_use_component = child
		elif child is EntityVariableStatsComponent:
			variable_stats_component = child
		elif child is EffectComponent:
			effect_component = child
		elif child is EffectDisplayComponent:
			effect_display_component = child
		elif child is InventoryEquipComponent:
			inventory_equip_component = child
