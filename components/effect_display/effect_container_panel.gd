extends Panel


const EFFECT_TOOLTIP_SCENE : PackedScene = preload("res://components/effect_display/scenes/effect_tooltip.tscn")


func _make_custom_tooltip(for_text : String):
	var text_array : PackedStringArray = for_text.split("||descsplit||")
	var effect_name : StringName = text_array[0]
	var effect_description : String = text_array[1]
	var effect_tooltip : Control = EFFECT_TOOLTIP_SCENE.instantiate()
	effect_tooltip.get_node("MarginContainer/EffectTooltip/Title").text = "[font_size=24][color=A8E752]%s[/color][/font_size]" % effect_name
	effect_tooltip.get_node("MarginContainer/EffectTooltip/Description").text = "[font_size=18][color=F1F1F1]%s[/color][/font_size]" % effect_description
	return effect_tooltip
