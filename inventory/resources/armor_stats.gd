extends ResourceStats
## A class for equippable items which grant passive buffs to the player, such as armor and clothing.
class_name ArmorStats


## How much damage will be substracted from the incoming attack while this item is equipped.
@export_category("Armor")
@export var DamageBlock : float


func _init():
	TypeIndexArray.append(3)
