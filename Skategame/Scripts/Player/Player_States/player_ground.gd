class_name CharacterStateGround
extends CharacterState

func enter() -> void:
	if state.previous_state.name == "Player_Air" or state.previous_state.name == "Player_Pipesnap_Air":
		anim.set_ground_landed()
	input.input_buffer.clear()
	
func exit() -> void:
	anim.reset_ground_landed()

func physics_update(_delta : float):
	_ground_movement(_delta, true)
	ctrl.handle_wall_bounce()
	if _handle_jump():
		return
	if _grind_lip_check():
		return
	
func _ground_movement(_delta, store: bool = false) -> void: 	
	ctrl.surface_check(false) 		
	ctrl.set_path()
	_ground_check()	
	if store:
		ctrl.last_ground_transform = ctrl.global_transform
	if input.get_input().y < 0:
		ctrl.velocity *= GlobalSettings.GROUND_SLOWDOWN
		ctrl.global_rotate(ctrl.xform.basis.y, input.get_input().x * ctrl.stats.rot_kickturn * _delta)
	else:
		ctrl.global_rotate(ctrl.xform.basis.y, input.get_input().x * ctrl.stats.rot * _delta)
	if input.get_input().y >= 0 and ctrl.velocity.length() < ctrl.stats.max_vel/8 and LibHelpers.forward_velocity(ctrl.velocity, ctrl.up_direction).length() > 0.1 or input.get_input().y > 0:
		ctrl.velocity += ctrl.xform.basis.z * ctrl.stats.acc * 0.25
	if (input.get_input().z > 0 and ctrl.velocity.length() <= ctrl.stats.max_vel and input.get_input().y != -1) or (input.get_input().z < 0 and ctrl.velocity.length() >= -ctrl.stats.max_vel):
		ctrl.velocity += ctrl.xform.basis.z * input.get_input().z * ctrl.stats.acc
	ctrl.velocity.y -= GlobalSettings.GRAVITY * _delta
	ctrl.velocity = LibHelpers.kill_orthogonal_velocity(ctrl.xform, ctrl.velocity)
	ctrl.set_previous_values()
	ctrl.set_char_up_direction()
	ctrl.global_transform = LibHelpers.align(ctrl.global_transform, ctrl.up_direction)
	ctrl.move_and_slide()
	if input.can_jump():
		ctrl.apply_floor_snap()
	anim.animation_handler_ground_pipe(_delta, ctrl.velocity)
	tricks.set_combo_cooldown(_delta)	
		
func _ground_check() -> void:
	if ctrl.shape_col_ground:
		var _coll_info = ctrl.shape_col_ground[0].collider
		var _coll_normal = ctrl.shape_col_ground[0].normal
		if _coll_info.is_in_group('pipe'):
			if ctrl.up_direction.dot(_coll_normal) > 0.995:
				transitioned.emit(self, "Player_Pipe")
				return
	else:
		ctrl.velocity += ctrl.up_direction * GlobalSettings.GRIND_END_UP_VEL
		transitioned.emit(self, "Player_Air")

func _handle_jump() -> bool:
	if input.get_input_jump():
		ctrl.velocity += Vector3.UP * ctrl.stats.jump_vel
		input.set_jump_cooldown()
		transitioned.emit(self, "Player_Air")
		return true
	return false

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
