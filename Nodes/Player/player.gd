extends RapierCharacterBody2D


const SPEED : float = 300.0
const BURST_SPEED : float = 2.5
const JUMP_VELOCITY : float = -400.0

var can_double_jump : bool = true
var can_jump : bool = true
var can_burst : bool = true
var can_move : bool = true
var bursting : bool = false
var gravity_enabled : bool = true
var locked_y : float = 0.0
var jumps_total : int = 0


func _physics_process(delta: float) -> void:
	_handle_gravity(delta)
	_handle_movement()
	_handle_jump()
	
	if bursting:
		position.y = locked_y
	
	if Input.is_action_just_pressed("burst"):
		_handle_burst()
	

func _handle_gravity(delta : float) -> void:
	if gravity_enabled and not bursting:
		if not is_on_floor():
			velocity += get_gravity() * delta
		else:
			can_burst = true
			can_double_jump = true
			jumps_total = 0

func _handle_movement() -> void:
	var direction : float = _get_current_direction()
	if can_move:
		if direction:
			if bursting:
				velocity.x = direction * SPEED * BURST_SPEED
			else:
				velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
		move_and_slide()

func _handle_jump() -> void:
	if can_jump:
		if Input.is_action_just_pressed("ui_accept") and (is_on_floor() or can_double_jump):
			velocity.y = JUMP_VELOCITY
			jumps_total += 1
			if jumps_total >= 1:
				can_double_jump = false

func _handle_burst() -> void:
	if can_burst:
		bursting = true
		locked_y = position.y
		await get_tree().create_timer(0.25).timeout
		bursting = false

func _get_current_direction() -> float:
	return Input.get_axis("ui_left", "ui_right")
