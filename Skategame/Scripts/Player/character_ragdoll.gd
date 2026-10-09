class_name CharacterRagdoll
extends Node

@onready var physical_bone_simulator_3d: PhysicalBoneSimulator3D = $"../../Character_Visual/Char_Physics/Skeleton3D/PhysicalBoneSimulator3D"
@onready var physical_bone_def_hips: PhysicalBone3D = $"../../Character_Visual/Char_Physics/Skeleton3D/PhysicalBoneSimulator3D/Physical Bone DEF-spine"
@onready var physical_bone_def_board: PhysicalBone3D = $"../../Character_Visual/Char_Physics/Skeleton3D/PhysicalBoneSimulator3D/Physical Bone DEF-board"
var active : bool = false

func _process(delta: float) -> void:
	_debug_ragdoll()
		
		
func _debug_ragdoll() -> void:
	if Input.is_action_just_pressed("ui_accept") and !active:
		active = true
		set_start_simulation(Vector3(0,0.1,0.25))
	if Input.is_action_just_released("ui_accept") and active:
		active = false
		set_end_simulation()
	

func set_start_simulation(_impulse) -> void:
	if !physical_bone_simulator_3d.active:
		print("start ragdoll physics")
		physical_bone_simulator_3d.active = true
		physical_bone_simulator_3d.physical_bones_start_simulation()
		physical_bone_def_hips.apply_central_impulse(_impulse * 10)
		physical_bone_def_board.apply_central_impulse(_impulse)
	
	
func set_end_simulation() -> void:
	if physical_bone_simulator_3d.active:
		print("end ragdoll physics")
		physical_bone_simulator_3d.active = false
		physical_bone_simulator_3d.physical_bones_stop_simulation()
