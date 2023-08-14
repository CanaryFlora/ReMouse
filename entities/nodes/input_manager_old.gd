extends Node
## Receives and responds to all player inputs.

## The speed at which the player moves, px/s.
@export var movementSpeed = 600
## The CharacterBody2D of the player.
@export var playerNode : CharacterBody2D
## The CollisionPolygon2D of the player.
@export var playerCollisionNode : Node2D
## The CollisionPoylgon2D which will be used when dashing.
@export var dashHitbox : Node2D

@onready var handLeft : Node = $"../LeftPoint/HandLeft"
@onready var handRight : Node = $"../RightPoint/HandRight"
@onready var leftPoint : Node = $"../LeftPoint"
@onready var rightPoint : Node = $"../RightPoint"
#@onready var effectManager : Node = $"../EffectManager"

## What direction the player is moving in on the x axis. 1 is right, 0 is none, -1 is left.
var xMov : int
## What direction the player is moving in on the y axis. 1 is down, 0 is none, -1 is up.
var yMov : int
## If the player's dash is on cooldown.
var dashOnCooldown : bool = false
## The current angle of the player.
var playerAngle : int
## The angle the player will be rotated towards.
var finalRotation : int
## The time it takes for the player to rotate to the final angle.
var rotationTime : float = 0.2

var mousePos : Vector2
var handRightToMouse
var handLeftToMouse
var currentHand : String = "left"
var leftAttackOnCooldown : bool
var rightAttackOnCooldown : bool
var attackCooldown : float = 0.2
var holdingLMB : bool


func _ready():
	dashHitbox.set_deferred("disabled", true)
	
func _physics_process(delta):
	#------------------------------------------------------------------#
	#------------------------Movement & Rotation-----------------------#
	#------------------------------------------------------------------#
#	effectManager.call("effect_timer")
	movement()
	var mouse_pos : Vector2 = get_viewport().get_mouse_position()
	var rotateOutput : int = rotate_node(xMov, yMov, playerNode)
	var negRotation : int = rotateOutput - 360
	var negRotationDeg : int
	if playerNode.rotation_degrees != rotateOutput:
		negRotationDeg = playerNode.rotation_degrees + abs(negRotation)
		var posRotationDeg : int = abs(rotateOutput - playerNode.rotation_degrees)
		if negRotationDeg < posRotationDeg:
			finalRotation = negRotation
		elif negRotationDeg >= posRotationDeg:
			finalRotation = rotateOutput
		var tween : Tween = get_tree().create_tween()
		tween.tween_property(playerNode, "rotation_degrees", finalRotation, rotationTime).from(playerNode.rotation_degrees).set_ease(Tween.EASE_OUT_IN)
		
	#------------------------------------------------------------------#
	#-------------------------Hands & Attacking------------------------#
	#------------------------------------------------------------------#
	
#	effectManager.call("effect_timer")
	mousePos = get_parent().get_global_mouse_position()
	# offset the angle difference by subtracting 90 deg
	handLeftToMouse = rad_to_deg(handLeft.get_angle_to(mousePos)) - 90
	handRightToMouse = rad_to_deg(handRight.get_angle_to(mousePos)) - 90
	# set closer to mouse variable, reset opposite hand to normal position
	var tween : Tween = get_tree().create_tween()
	if currentHand == "left":
		tween.tween_property(leftPoint, "rotation_degrees", rotation_cap(handLeftToMouse, false), 0.1)
	elif currentHand == "right":
		tween.tween_property(rightPoint, "rotation_degrees", rotation_cap(handRightToMouse, true), 0.1)
	oneHandAttack()


## When run, checks if the player is currently pressing the dash key, if so, increases their speed for a time until the dash has run out, then reverts their speed and applies the dash cooldown effect.
func movement() -> void:
	xMov = Input.get_action_strength("Right") - Input.get_action_strength("Left")
	yMov = Input.get_action_strength("Down") - Input.get_action_strength("Up") 
	if Input.is_action_pressed("DashKey") and dashOnCooldown == false:
		# set dash to be on cooldown, increase speed, enable dash hitbox
		dashOnCooldown = true
#		print("pressed")
		movementSpeed =  movementSpeed * 2.5
		playerCollisionNode.set_deferred("disabled", true)
		dashHitbox.set_deferred("disabled", false)
		await get_tree().create_timer(0.3).timeout
		# revert changes, apply cd effect
		movementSpeed = movementSpeed / 2.5
		playerCollisionNode.set_deferred("disabled", false)
		dashHitbox.set_deferred("disabled", true)
		# apply dash cd effect
	playerNode.velocity = Vector2(xMov, yMov).normalized() * movementSpeed
	playerNode.move_and_slide()
	

## Utility function for rotating the player. Determines the player's rotations based on their xMov and yMov.
func rotate_node(xMov : int, yMov : int, node : Node) -> int:
	match yMov:
		1:
			match xMov:
				1:
					playerAngle = 315
				0:
					playerAngle = 360
				-1:
					playerAngle = 45
		0:
			match xMov:
				1:
					playerAngle = 270
				-1:
					playerAngle = 90
		-1:
			match xMov:
				1:
					playerAngle = 225
				0:
					playerAngle = 180
				-1:
					playerAngle = 135
	return playerAngle


func oneHandAttack():
	if holdingLMB:
		if currentHand == "left":
			if leftAttackOnCooldown == false:
				leftAttackOnCooldown = true
				# play animation first part (move hand forward)
				var tween3 : Tween = get_tree().create_tween()
				tween3.tween_property(handLeft, "position", Vector2(handLeft.position.x, handLeft.position.y + 50), 0.2)
				await get_tree().create_timer(0.2).timeout
				var tween4 : Tween = get_tree().create_tween()
				tween4.tween_property(handLeft, "position", Vector2(-3, 10), 0.2)
				await get_tree().create_timer(attackCooldown).timeout
				leftAttackOnCooldown = false
				
				
	if holdingLMB:
		if currentHand == "right":
			if rightAttackOnCooldown == false:
				rightAttackOnCooldown = true
				var tween5 : Tween = get_tree().create_tween()
				tween5.tween_property(handRight, "position", Vector2(handRight.position.x, handRight.position.y + 50), 0.2)
				await get_tree().create_timer(0.2).timeout
				var tween6 : Tween = get_tree().create_tween()
				tween6.tween_property(handRight, "position", Vector2(3, 10), 0.2)
				await get_tree().create_timer(attackCooldown).timeout
				rightAttackOnCooldown = false


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

func _unhandled_input(event):
	# switch hands with right click
	if Input.is_action_just_pressed("RightClick") and currentHand == "left":
		var eTween : Tween = get_tree().create_tween()
		currentHand = "right"
		eTween.tween_property(leftPoint, "rotation_degrees", 0, 0.1)
		print("switched to right")
	elif Input.is_action_just_pressed("RightClick") and currentHand == "right":
		var eTween2 : Tween = get_tree().create_tween()
		currentHand = "left"
		eTween2.tween_property(rightPoint, "rotation_degrees", 0, 0.1)
		print("switched to left")
	if event.is_action_pressed("LeftClick", false):
		holdingLMB = true
#		print("pressed")
	if event.is_action_released("LeftClick", false):
		holdingLMB = false
