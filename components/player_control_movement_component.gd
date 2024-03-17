extends Node
## A class that provides player-controllable movement to an entity.
class_name PlayerControlMovementComponent

## The base movement speed of the entity.
@export var base_movement_speed : int
## If this entity can use precise movement.
@export var can_use_precise_movement : bool
## The minimum precise movement turning time.
@export var min_turn_time : float

## The parent node of the entity.
@onready var entity_node : Node2D = get_parent()
## The entity's current movement speed.
@onready var movement_speed : int = base_movement_speed

## What direction the entity is moving in on the x axis. 1 is right, 0 is none, -1 is left.
var x_mov : int
## What direction the entity is moving in on the y axis. 1 is down, 0 is none, -1 is up.
var y_mov : int
## If the player's dash is on cooldown.
var dash_on_cooldown : bool = false
## The current angle of the entity.
var entity_angle : float 
## The angle the entity will be rotated towards.
var final_rotation : float
## An array of tweens that are being used for precise rotation.
var rotation_tween_array : Array[Tween]
var movement_pressed : bool

func _physics_process(delta):
	rotation()
	if movement_pressed:
		basic_movement()

func rotation():
	var rotation_tween : Tween = get_tree().create_tween()
	var pos_angle_to_cursor : float = rad_to_deg(entity_node.get_angle_to(entity_node.get_global_mouse_position())) + 270
	var neg_angle_to_cursor : float = pos_angle_to_cursor - 360
	var final_angle_to_cursor : float = pos_angle_to_cursor
	var chosen_angle : String = "pos"
	if abs(neg_angle_to_cursor) < abs(pos_angle_to_cursor):
		final_angle_to_cursor = neg_angle_to_cursor
		chosen_angle = "neg"
	var delay : float = abs(final_angle_to_cursor / 200)
	var final_delay : float = delay
	if delay < min_turn_time:
		final_delay = min_turn_time
	elif delay >= min_turn_time:
		final_delay = delay
#	print("rotation: ", entity_node.rotation_degrees, " to rotate ", entity_node.to_rotate, " delay ", delay, " final delay ", delay)
#	print("pos angle to cursor: ", pos_angle_to_cursor, " neg angle to cursor: ", neg_angle_to_cursor, " chosen angle: ", chosen_angle)
#	print("tween array children: ", rotation_tween_array.size())
	rotation_tween_array.append(rotation_tween)
	rotation_tween.tween_property(entity_node, "to_rotate", final_angle_to_cursor, final_delay).as_relative()
	await get_tree().create_timer(delay + 0.5).timeout
	rotation_tween_array.erase(rotation_tween)
	rotation_tween.kill()

func basic_movement():
	var movement_speed_x : float
	var movement_speed_y : float
	#print("velocity: ", entity_node.linear_velocity, " damp ", snapped(entity_node.linear_damp, 0.01))
	entity_node.apply_central_force(movement_vector() * movement_speed)

func _unhandled_input(event):
	if event.is_action_pressed("move_forward"):
		movement_pressed = true
	elif event.is_action_released("move_forward"):
		movement_pressed = false

func movement_vector() -> Vector2:
	return (entity_node.get_global_mouse_position() - entity_node.position).normalized()

func stop_mouse_rotation():
	for rotation_tween in rotation_tween_array:
		rotation_tween.kill()
	print("all tweens killed")

