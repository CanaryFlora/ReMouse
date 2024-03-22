extends ControlableEntity
## A controllable entity that the player is meant to play as.
class_name Player


@export_group("Settings")
## If the player's special mouse ability is enabled.
@export var ability_enabled : bool
## The CollisionPolygon2D of the entity.
@export var entity_collision_node : Node2D
## The CollisionPoylgon2D which will be used when dashing if the player is a Roachmouse.
@export var dash_hitbox : Node2D


@onready var hand_left : Node = get_node("LeftPoint/HandLeft")
@onready var hand_right : Node = get_node("RightPoint/HandRight")
@onready var left_point : Node = get_node("LeftPoint")
@onready var right_point : Node = get_node("RightPoint")


var current_hand : String = "left"
var left_attack_on_cooldown : bool
var right_attack_on_cooldown : bool
var switch_hand_on_cooldown : bool
var switch_hand_cooldown_length : float = 0.5
var global_attack_cooldown_length : float = 0.3
var precise_movement_enabled : bool
var currently_attacking : bool


func _ready():
	# register panku stuff
	Panku.gd_exprenv.register_env("player", self)
	Panku.gd_exprenv.register_env("player_inventory_component", inventory_component)
	Panku.gd_exprenv.register_env("player_inventory_use_component", inventory_use_component)
	Panku.gd_exprenv.register_env("player_effect_component", effect_component)
	Panku.gd_exprenv.register_env("player_variable_stats_component", variable_stats_component)
	effect_component.apply_effect("Health Boost", 100)
	effect_component.apply_effect("Roundcap Poison", 100)


func _physics_process(delta):
	pass
	#if check_attack() == true:
		#one_hand_attack()


func rotation_cap(val : int, invert : bool) -> int:
	if invert == false:
		if val < -120 and val > -300:
			val = 90
		if val < -40:
			val = -40
	if invert == true:
		if val < -90 and val > -300:
			val = -90
		if val > 40:
			val = 40
	return val


#func _unhandled_input(event):
	## switch hands with right click
	#if event.is_action_pressed("use_left_hand_primary") and current_hand == "left":
		#var reset_rotation_tween : Tween = get_tree().create_tween()
		#current_hand = "right"
		#reset_rotation_tween.tween_property(left_point, "rotation_degrees", 0, 0.1)
		#if switch_hand_on_cooldown == false:
			#switch_hand_on_cooldown = true
			#await get_tree().create_timer(switch_hand_cooldown_length).timeout
			#switch_hand_on_cooldown = false
	#elif event.is_action_pressed("use_right_hand_primary") and current_hand == "right":
		#var reset_rotation_tween : Tween = get_tree().create_tween()
		#current_hand = "left"
		#reset_rotation_tween.tween_property(right_point, "rotation_degrees", 0, 0.1)
		#if switch_hand_on_cooldown == false:
			#switch_hand_on_cooldown = true
			#await get_tree().create_timer(switch_hand_cooldown_length).timeout
			#switch_hand_on_cooldown = false
#######################################################################################################
	#if event.is_action_pressed("use_left_hand_primary"):
		#currently_attacking = true
	#elif event.is_action_released("use_left_hand_primary"):
		#currently_attacking = false
	#pass


#func check_attack() -> bool:
	#if switch_hand_on_cooldown == false and currently_attacking == true:
		#return true
	#else:
		#return false


#func one_hand_attack() -> void:
	#match current_hand:
		#"left":
			#if left_attack_on_cooldown == false:
				#left_attack_on_cooldown = true
				## move hand forward
				#var left_move_forward_tween : Tween = get_tree().create_tween()
				#left_move_forward_tween.tween_property(hand_left, "position", Vector2(hand_left.position.x, hand_left.position.y + 50), 0.2)
				#await get_tree().create_timer(0.2).timeout
				## move hand back
				#var left_move_back_tween : Tween = get_tree().create_tween()
				#left_move_back_tween.tween_property(hand_left, "position", Vector2(-3, 10), 0.2)
				#await get_tree().create_timer(global_attack_cooldown_length).timeout
				#left_attack_on_cooldown = false
		#"right":
			#if right_attack_on_cooldown == false:
				#right_attack_on_cooldown = true
				#var right_move_forward_tween : Tween = get_tree().create_tween()
				#right_move_forward_tween.tween_property(hand_right, "position", Vector2(hand_right.position.x, hand_right.position.y + 50), 0.2)
				#await get_tree().create_timer(0.2).timeout
				#var right_move_back_tween : Tween = get_tree().create_tween()
				#right_move_back_tween.tween_property(hand_right, "position", Vector2(3, 10), 0.2)
				#await get_tree().create_timer(global_attack_cooldown_length).timeout
				#right_attack_on_cooldown = false


#func _on_entity_variable_stats_component_stat_reached_max_value(StatPropertiesResource):
	#get_parent().variable_stats.StatsArray.erase(StatPropertiesResource)
