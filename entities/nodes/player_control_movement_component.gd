extends Node
class_name PlayerControlMovementComponent
## A class that provides player-controllable movement to an entity.

## The speed at which the entity moves, px/s.
@export var movementSpeed = 600
## The CharacterBody2D of the entity.
@export var entityNode : Node2D
## The CollisionPolygon2D of the entity.
@export var entityCollisionNode : Node2D
## The CollisionPoylgon2D which will be used when dashing.
@export var dashHitbox : Node2D


## What direction the entity is moving in on the x axis. 1 is right, 0 is none, -1 is left.
var xMov : int
## What direction the entity is moving in on the y axis. 1 is down, 0 is none, -1 is up.
var yMov : int
## If the player's dash is on cooldown.
var dashOnCooldown : bool = false
## The current angle of the entity.
var entityAngle : float 
## The angle the entity will be rotated towards.
var finalRotation : int
## The time it takes for the entity to rotate to the final angle.
var rotationTime : float = 0.2
## If the current entity can dash. Is determined by checking if playerCollisionNode and dashHitbox is not null.
var dashEnabled : bool

func _ready():
	if entityCollisionNode != null and dashHitbox != null:
		dashEnabled = true
	if dashEnabled == true:
		dashHitbox.set_deferred("disabled", true)
#	print("Dash for ", get_parent(), " : ", dashEnabled)
	
func _physics_process(delta):
	#------------------------------------------------------------------#
	#------------------------Movement & Rotation-----------------------#
	#------------------------------------------------------------------#
#	effectManager.call("effect_timer")
	movement()
	var mouse_pos : Vector2 = get_viewport().get_mouse_position()
	var rotateOutput : int = rotate_entity(xMov, yMov, entityNode)
	var negRotation : int = rotateOutput - 360
	var negRotationDeg : int
	if entityNode.rotation_degrees != rotateOutput:
		negRotationDeg = entityNode.rotation_degrees + abs(negRotation)
		var posRotationDeg : int = abs(rotateOutput - entityNode.rotation_degrees)
		if negRotationDeg < posRotationDeg:
			finalRotation = negRotation
		elif negRotationDeg >= posRotationDeg:
			finalRotation = rotateOutput
		var tween : Tween = get_tree().create_tween()
		tween.tween_property(entityNode, "rotation_degrees", finalRotation, rotationTime).from(entityNode.rotation_degrees).set_ease(Tween.EASE_OUT_IN)



## When run, checks if the player is currently pressing the dash key, if so, increases their speed for a time until the dash has run out, then reverts their speed and applies the dash cooldown effect.
func movement() -> void:
	xMov = Input.get_action_strength("Right") - Input.get_action_strength("Left")
	yMov = Input.get_action_strength("Down") - Input.get_action_strength("Up") 
	if Input.is_action_pressed("DashKey") and dashOnCooldown == false and dashEnabled == true:
		# set dash to be on cooldown, increase speed, enable dash hitbox
		dashOnCooldown = true
#		print("pressed")
		movementSpeed =  movementSpeed * 2.5
		entityCollisionNode.set_deferred("disabled", true)
		dashHitbox.set_deferred("disabled", false)
		await get_tree().create_timer(0.3).timeout
		# revert changes, apply cd effect
		movementSpeed = movementSpeed / 2.5
		entityCollisionNode.set_deferred("disabled", false)
		dashHitbox.set_deferred("disabled", true)
		# apply dash cd effect
	entityNode.velocity = Vector2(xMov, yMov).normalized() * movementSpeed
	entityNode.move_and_slide()
	

## Utility function for rotating an entity. Determines the entity's rotations based on their xMov and yMov.
func rotate_entity(xMov : int, yMov : int, node : Node) -> int:
	match yMov:
		1:
			match xMov:
				1:
					entityAngle = 315
				0:
					entityAngle = 360
				-1:
					entityAngle = 45
		0:
			match xMov:
				1:
					entityAngle = 270
				-1:
					entityAngle = 90
		-1:
			match xMov:
				1:
					entityAngle = 225
				0:
					entityAngle = 180
				-1:
					entityAngle = 135
	return entityAngle

