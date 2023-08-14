extends ResourceStats
## A class which stores the information for tools, such as how much damage they do or how much of a certain resource they harvest.
class_name ToolStats


@export_group("Tool")
## How much damage the tool does to entities.
@export var ItemDamage : int
## How much wood is harvested from wood type props.
@export var ItemWoodHarvest : int
## How much stone is harvested from stone type props.
@export var ItemStoneHarvest : int

func _init():
	TypeIndexArray.append(2)
