extends Node
class_name EffectComponent


signal effect_applied(effect : Effect)
signal effect_ended(effect : Effect)
signal effect_extended(effect : Effect)


## The node which will have it's properties changed when an effect is applied.
@export var target : Node
## The maximum amount of effects this entity can be affected by at once.
@export var max_effects : int
## The effects which cannot be applied to this entity.
@export var effect_blacklist : Array[Effect]
## The EntityVariableStatsComponent of this entity.
@export var stats_component : EntityVariableStatsComponent


## The current effects applied to this entity.
var current_effects : Array[Effect]

## A dictionary containing all the effects and their resources.
const effect_database : Dictionary = {
	"Roundcap Poison": preload("res://effects/roundcap_poison.tres"),
	"Health Boost": preload("res://effects/health_boost.tres"),
}

## Searches the effect database for an effect with name corresponding to effect_name and applies it for duration.
func apply_effect(effect_name : StringName, duration : float):
	var effect : Effect = effect_database[effect_name].duplicate(true)
	if not is_effect_blacklisted(effect_name):
		if not is_effect_applied(effect_name) or effect.stacking_mode == "Stack":
			if len(current_effects) < max_effects:
				## setup timer
				var effect_timer : Timer = Timer.new()
				effect.timer = effect_timer
				effect_timer.wait_time = duration
				self.add_child(effect_timer)
				effect_timer.one_shot = true
				## append effect to current effects array
				current_effects.append(effect)
				## what to do when effect is applied
				match effect.name:
					"Roundcap Poison":
						var poison_timer : Timer = Timer.new()
						var health_stat : StatProperties = stats_component.find_stat("Health")
						poison_timer.wait_time = 0.1
						poison_timer.timeout.connect(func():
							health_stat.stat_value -= 1)
						self.add_child(poison_timer)
						poison_timer.start()
						effect_timer.timeout.connect(func():
							poison_timer.queue_free()
							)
					"Health Boost":
						var health_stat : StatProperties = stats_component.find_stat("Health")
						health_stat.max_value += 30
						get_node(health_stat.progress_bar_node_path).max_value += 30
						effect_timer.timeout.connect(func():
							health_stat.max_value -= 30
							get_node(health_stat.progress_bar_node_path).max_value -= 30
							)
				effect_timer.timeout.connect(func():
					current_effects.erase(effect)
					emit_signal("effect_ended", effect))
				effect_timer.start()
				emit_signal("effect_applied", effect)
				print("Applied new effect %s to %s" % [effect.name, target.name])
			elif len(current_effects) >= max_effects:
				if effect.overflow_mode == "Replace":
					var old_effect : Effect = current_effects.back()
					shorten_effect(current_effects.back().name.to_snake_case())
					apply_effect(effect_name, duration)
					print("Replaced oldest effect %s with new effect %s" % [old_effect.name, effect.name])
				elif effect.overflow_mode == "Discard":
					print("All effect slots filled and effect overflow mode set to Discard, effect %s will not be applied" % effect.name)
		elif is_effect_applied(effect_name):
			effect = get_applied_effect(effect_name)
			match effect.stacking_mode:
				"Override":
					shorten_effect(effect_name)
					apply_effect(effect_name, duration)
					print("Replaced effect %s with a new instance of %s" % [effect.name, effect.name])
				"Duration":
					var current_duration : float = effect.timer.time_left
					effect.timer.stop()
					effect.timer.wait_time = current_duration + duration
					effect.timer.start()
					emit_signal("effect_extended", effect)
					print("Duration of effect %s increased by %s from %s to %s" % [effect.name, duration, current_duration, effect.timer.time_left])
	elif is_effect_blacklisted(effect_name):
		print("Effect %s is blacklisted for this EffectComponent, discarding effect" % effect.name)


## Shortens the currently applied effect with the name corresponding to effect_name by duration.
func shorten_effect(effect_name : StringName, duration : float = INF):
	var effect : Effect = get_applied_effect(effect_name)
	if effect != null:
		var current_duration : float = effect.timer.time_left
		if current_duration - duration <= 0:
			effect.timer.stop()
			effect.timer.emit_signal("timeout")
			effect.timer.queue_free()
			print("%s duration reached 0, removing effect" % effect.name)
		else:
			effect.timer.stop()
			effect.timer.wait_time = current_duration - duration
			effect.timer.start()
			print("%s duration shortened by %s" % [effect.name, duration])
	else:
		print("Could not find effect %s in currently applied effects array" % effect_name)


func is_effect_applied(effect_name : StringName) -> bool:
	for effect : Effect in current_effects:
		if effect.name.to_snake_case() == effect_name:
			return true
	return false


func is_effect_blacklisted(effect_name : StringName) -> bool:
	for effect : Effect in effect_blacklist:
		if effect.name.to_snake_case() == effect_name:
			return true
	return false


func get_applied_effect(effect_name : StringName) -> Effect:
	for effect : Effect in current_effects:
		if effect.name.to_snake_case() == effect_name:
			return effect
	return null

