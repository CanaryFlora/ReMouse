extends Entity
## An entity which can be controlled by the player.
class_name ControlableEntity

var to_rotate : float

func _integrate_forces(state):
	rotation_degrees = to_rotate
