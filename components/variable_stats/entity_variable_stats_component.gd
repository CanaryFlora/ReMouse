extends Node
## A class that manages and updates an entity's different stats.
## When a stat update happens, the stat is added or subtracted from depending on its gain and decay settings.
class_name EntityVariableStatsComponent

## Emitted when all of the stats are ready for use.
signal stats_ready
## Emitted when any stat's value is the same or lower than its min_value.
signal stat_reached_min_value(stat_properties_resource : StatProperties)
## Emitted when any stat's value is the same or higher than its max_value.
signal stat_reached_max_value(stat_properties_resource : StatProperties)
## Emitted when any stat is incremented.
signal stat_incremented(stat_properties_resource : StatProperties)

## An array of stats that this entity will have.
@export var stats_array : Array[StatProperties]


func _ready():
	setup_stats()



func _physics_process(delta):
	update_stats()


## Sets up every stat's value, syncs it to its ProgressBar, and creates a timer for updating.
func setup_stats() -> void:
	for stat_properties_resource : StatProperties in stats_array:
		if get_node_or_null(stat_properties_resource.progress_bar_node_path) != null:
			var progress_bar_node : Range = get_node(stat_properties_resource.progress_bar_node_path)
			stat_properties_resource.stat_value = stat_properties_resource.starting_value
			progress_bar_node.value = stat_properties_resource.starting_value
			progress_bar_node.min_value = stat_properties_resource.min_value
			progress_bar_node.max_value = stat_properties_resource.max_value
		var stat_timer : Timer = Timer.new()
		self.add_child(stat_timer)
		stat_timer.wait_time = stat_properties_resource.increment_rate
		stat_timer.timeout.connect(increment_stat.bind(stat_properties_resource))
		stat_timer.start()
	emit_signal("stats_ready")


## Substracts the stat's decay value from it and then adds the gain value.
func increment_stat(stat_properties_resource : StatProperties) -> void:
	var new_value : float = stat_properties_resource.stat_value + stat_properties_resource.gain - stat_properties_resource.decay
	stat_properties_resource.stat_value = new_value
	update_stats()


## Syncs all stats' properties with their ProgressBar nodes, emits signals, and stops values from going over or under min_value/max_value.
func update_stats():
	for stat_properties_resource in stats_array:
		if stat_properties_resource.stat_value <= stat_properties_resource.min_value:
			stat_properties_resource.stat_value = stat_properties_resource.min_value
		elif stat_properties_resource.stat_value >= stat_properties_resource.max_value:
			stat_properties_resource.stat_value = stat_properties_resource.max_value
		if get_node_or_null(stat_properties_resource.progress_bar_node_path) != null:
			var progress_bar_node : Range = get_node(stat_properties_resource.progress_bar_node_path)
			progress_bar_node.value = stat_properties_resource.stat_value
		if stat_properties_resource.stat_value == stat_properties_resource.min_value:
			emit_signal("stat_reached_min_value", stat_properties_resource)
		elif stat_properties_resource.stat_value == stat_properties_resource.max_value:
			emit_signal("stat_reached_max_value", stat_properties_resource)


## Looks for a variable stat with the specified name, returns the StatProperties if found and null if not.
func find_stat(stat_name : StringName):
	for stat in stats_array:
		if stat.stat_name == stat_name:
			return stat
	return null
