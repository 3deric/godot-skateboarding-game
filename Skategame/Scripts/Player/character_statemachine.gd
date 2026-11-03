class_name CharacterStatemachine
extends Node

@export var initial_state : CharacterState
@onready var char_ctrl : CharacterController = $"../../Character"

var current_state : CharacterState
var previous_state : CharacterState
var states : Dictionary = {}

func init():
	for child in get_children():
		if child is CharacterState:
			states[child.name.to_lower()] = child
			child.transitioned.connect(on_child_transition)
			child.init(char_ctrl, char_ctrl.Char_Statemachine, char_ctrl.Char_Input, char_ctrl.Char_Animation, char_ctrl.Char_Tricks, char_ctrl.Char_Fall)
			
	if initial_state:
		initial_state.enter()
		current_state = initial_state
	print("Transitioning to Player State: " + current_state.name)

			
func process(delta) -> void:
	if current_state:
		current_state.update(delta)
		
func physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)

func on_child_transition(state : CharacterState, new_state_name : String):
	if state != current_state:
		return	
	previous_state = current_state
	var new_state = states.get(new_state_name.to_lower())
	if !new_state:
		return		
	print("Transitioning to State: " + new_state.name)
	if current_state:
		current_state.exit()		
	new_state.enter()
	current_state = new_state

	
func set_force_state(new_state_name : String):
	previous_state = current_state
	var new_state = states.get(new_state_name.to_lower())
	if current_state:
		current_state.exit()
	new_state.enter()
	current_state = new_state
	print("Transitioning to State: " + new_state.name)
