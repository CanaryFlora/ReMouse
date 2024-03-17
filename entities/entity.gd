extends PhysicsBody2D
## A specialized CharacterBody2D for an entity in ReMouse.
class_name Entity

@export_group("Entity")
# A list of components for use by the entity. Not all components are required for an entity to function.
@export var inventory_component : InventoryComponent
@export var inventory_display_component : InventoryDisplayComponent
@export var player_movement_component : PlayerControlMovementComponent
@export var inventory_use_component : InventoryUseComponent
@export var variable_stats_component : EntityVariableStatsComponent
@export var effect_component : EffectComponent
@export var effect_display_component : EffectDisplayComponent
