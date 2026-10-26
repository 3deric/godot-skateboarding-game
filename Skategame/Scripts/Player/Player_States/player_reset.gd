extends CharacterState

func enter() -> void:
	_reset_player()
	ctrl.surface_check(false, false)
	
func exit() -> void:
	pass

func update(delta : float):
	if Input.is_action_pressed("Up"):
		transitioned.emit(self, "Player_Ground")

func _reset_player() -> void:
	var _transform = ctrl.last_ground_transform
	#ctrl.Ingame_Ui.set_fail_view(false)
	#ctrl.Ingame_Ui.set_balance_view(false)
	#ctrl.Char_Ragdoll.set_end_simulation()

	ctrl.standing_timer = GlobalSettings.STANDING_TIMER
	ctrl.up_direction = Vector3.UP
	ctrl.velocity = Vector3.ZERO
	ctrl.last_vel = Vector3.ZERO
	ctrl.global_transform = _transform
	ctrl.Camera_Pos.global_position = _transform.origin
	ctrl.balance_angle = 0.0
	ctrl.Char_Input.reset()
	anim.init(true)
	anim.reset_vis_balance()
