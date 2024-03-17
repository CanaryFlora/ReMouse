extends Resource
## Used to define the basic settings of a entity variable stat.
class_name StatProperties

@export var stat_name : StringName
## The minimum value for the stat.
@export var min_value : float
## The maximum value for the stat.
@export var max_value : float
## The value an entity stats with when it has this stat.
@export var starting_value : float
## The amount subtracted from the stat when the stat is updated.
@export var decay : float
## The amount added to the stat when the stat is updated.
@export var gain : float
## The amount of time to wait between a stat increment cycle. Each increment cycle the stat gets Gain added to it and Decay subtracted.
@export var increment_rate : float
## The ProgressBar node which displays this stat's information.
@export_node_path("ProgressBar", "TextureProgressBar") var progress_bar_node_path : NodePath

## The current value of the stat.
var stat_value : float
