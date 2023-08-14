extends Node
## An abstract class for transferring basic data into a SaveResource. Not meant for practical use, only use if you know what you're doing.
class_name SaveComponent

@export_group("Basic Saving")
## The save file name.
@export var SaveFileName : String

# The final path where the resource
var FinalPath : String

