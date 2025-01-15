extends CharacterBody2D


const SPEED = 60
const JUMP_VELOCITY = -40
var level = 0


func _physics_process(delta: float) -> void:
	var direction = Input.get_vector("left", "right", "up", "down")
	if direction:
		self.velocity = direction * SPEED
	else:
		self.velocity = Vector2.ZERO
	move_and_slide()
