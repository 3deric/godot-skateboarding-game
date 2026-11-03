extends CharacterState

const SURFACE_TIMER_DELAY : float = 0.1
var surface_timer : float

func enter():
	if state.previous_state.name != "Player_Pipesnap_Air":
		tricks.set_start_air()
	ctrl.set_path_null()
	surface_timer = SURFACE_TIMER_DELAY
	
func exit():
	tricks.set_end_trick()

func physics_update(_delta : float):
	_air_movement(_delta)
	tricks.set_air_trick()
	if _grind_lip_check():
		return
	if fall.get_fall_out_of_bounds(ctrl.global_position):
		transitioned.emit(self, "Player_Fall")
		return

func _air_movement(_delta) -> void: 	
	ctrl.surface_check(true)
	ctrl.set_path()
	var _rot_delta = ctrl.Char_Input.get_input().x * ctrl.stats.rot_jump * _delta
	ctrl.global_rotate(ctrl.xform.basis.y, _rot_delta)
	ctrl.velocity.y -= GlobalSettings.GRAVITY * _delta
	ctrl.up_direction = lerp(ctrl.up_direction,Vector3.UP, _delta * GlobalSettings.UP_ALIGN_SPEED)
	ctrl.set_previous_values()
	if _surface_check_delay(_delta):
		_ground_check()
	ctrl.set_char_up_direction()
	ctrl.global_transform = LibHelpers.align(ctrl.global_transform, ctrl.up_direction)
	ctrl.move_and_slide()
	
func _ground_check() -> void:
	if ctrl.shape_col_ground:
		var _coll_info = ctrl.shape_col_ground[0].collider
		if _coll_info.is_in_group("wall"):
			return
		
		if fall.get_fall_landed_perpendicular(ctrl.xform, ctrl.velocity, ctrl.up_direction):
			transitioned.emit(self, "Player_Fall")
			return
		if _coll_info.is_in_group('pipe'):
			transitioned.emit(self, "Player_Pipe")
			return
		if ctrl.up_direction.dot(Vector3.UP) < 0.5:
			return
		if _coll_info.is_in_group('floor'):
			transitioned.emit(self, "Player_Ground")

func _grind_lip_check() -> bool:
	if !input.get_input_grind():
		return false
	if ctrl.get_can_grind():
		transitioned.emit(self, "Player_Grind")
		return true
	elif ctrl.get_can_lip():
		transitioned.emit(self, "Player_Lip")
		return true
	return false
	
func _surface_check_delay(_delta : float) -> bool:
	if surface_timer >= 0:
		surface_timer -= _delta
	if surface_timer <= 0:
		return true
	return false
