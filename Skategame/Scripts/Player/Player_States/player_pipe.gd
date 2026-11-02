extends CharacterStateGround

func enter() -> void:
	if state.previous_state.name == "Player_Air" or state.previous_state.name == "Player_Pipesnap":
		anim.set_ground_landed()
	input.input_buffer.clear()
	
func exit() -> void:
	pass

func physics_update(_delta : float):
	_ground_movement(_delta)
	ctrl.handle_wall_bounce()
	if _handle_jump():
		return	
	if _pipesnap_check():
		return
	if _grind_lip_check():
		return

func _pipesnap_check() -> bool:
	var _pipesnap : Dictionary = ctrl.get_pipesnap()
	if !_pipesnap.valid == true:
		return false
	if _pipesnap.air == false:
		transitioned.emit(self, "Player_Pipesnap")
		return true
	else:
		ctrl.velocity -= ctrl.up_direction * 0.5
		transitioned.emit(self, "Player_Air")	
		return true
	return false

func _ground_check() -> void:
	if ctrl.shape_col_ground:
		var _coll_info = ctrl.shape_col_ground[0].collider
		var _coll_normal = ctrl.shape_col_ground[0].normal
		if _coll_info.is_in_group('floor'):
			transitioned.emit(self, "Player_Ground")
			return
	else:
		transitioned.emit(self, "Player_Air")
		
func _handle_jump() -> bool:
	if input.get_input_jump():
		ctrl.velocity += Vector3.UP * ctrl.stats.jump_vel
		input.set_jump_cooldown()
		if ctrl.get_pipesnap(true).valid == true:
			transitioned.emit(self, "Player_Pipesnap")
			return true
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
