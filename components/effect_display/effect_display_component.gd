extends EffectComponent
class_name EffectDisplayComponent


@export var effect_grid : Control
@export_enum("Timers", "Bars") var effect_display_type : String = "Timers"


var effect_container_array : Array[Control]


const EFFECT_CONTAINER_TIMER_SCENE : PackedScene = preload("res://components/effect_display/scenes/effect_container_timer.tscn")
const EFFECT_CONTAINER_BAR_SCENE : PackedScene = preload("res://components/effect_display/scenes/effect_container_bar.tscn")
const BUFF_THEME : Theme = preload("res://components/effect_display/themes/buff_theme.tres")
const DEBUFF_THEME : Theme = preload("res://components/effect_display/themes/debuff_theme.tres")
const MIXED_EFFECT_THEME : Theme = preload("res://components/effect_display/themes/mixed_effect_theme.tres")


func _ready():
	self.effect_ended.connect(remove_effect_container)
	self.effect_applied.connect(add_effect_container)


func _physics_process(delta):
	update_effects()


func add_effect_container(effect : Effect):
	match effect_display_type:
		"Timers":
			var effect_container : Control = EFFECT_CONTAINER_TIMER_SCENE.instantiate()
			effect_container.get_node("Panel").get_node("CenterContainer").get_node("TextureRect").texture = effect.icon
			effect.effect_container = effect_container
			effect_container.get_node("Panel").tooltip_text = effect.name + "||descsplit||" + effect.description
			if len(effect_container_array) < 8:
				effect_grid.get_node("CenterContainer2").get_node("Row2").add_child(effect_container)
			else:
				effect_grid.get_node("CenterContainer1").get_node("Row1").add_child(effect_container)
			effect_container_array.append(effect_container)
			match effect.type:
				"Buff":
					effect_container.get_node("Panel").theme = BUFF_THEME
				"Debuff":
					effect_container.get_node("Panel").theme = DEBUFF_THEME
				"Mixed":
					effect_container.get_node("Panel").theme = MIXED_EFFECT_THEME
		"Bars":
			pass


func update_effects():
	for effect : Effect in current_effects:
		match effect_display_type:
			"Timers":
				effect.effect_container.get_node("Label").text = str(ceil(effect.timer.time_left)) + "s"
			"Bars":
				pass


func remove_effect_container(effect : Effect):
	if effect.effect_container != null:
		effect.effect_container.queue_free()
		effect_container_array.erase(effect.effect_container)
