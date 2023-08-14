extends CharacterBody2D

var Inventory : InventoryComponent
var MovementDash : PlayerControlMovementComponent
var EquippedInLeft : InventorySlotResource
var EquippedInRight : InventorySlotResource

func _ready():
	Inventory = get_node("InventoryComponent")
	MovementDash = get_node("PlayerControlMovementComponent")
	Panku.gd_exprenv.register_env("Player", self)

