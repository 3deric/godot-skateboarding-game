class_name CharacterRagdoll
extends Node

@onready var physical_skeleton : Skeleton3D = $"../../Character_Visual/Char_Physics/Skeleton3D"
@onready var target_skeleton : Skeleton3D = $"../../Character_Visual/Char_Skeleton/Skeleton3D"

@onready var physical_bone_simulator : PhysicalBoneSimulator3D = $"../../Character_Visual/Char_Physics/Skeleton3D/PhysicalBoneSimulator3D"

@export var linear_spring_stiffness: float = 1200.0
@export var linear_spring_damping: float = 40.0
@export var max_linear_force: float = 9999.0

@export var angular_spring_stiffness: float = 4000.0
@export var angular_spring_damping: float = 80.0
@export var max_angular_force: float = 9999.0

var physics_bones

var _delta: float = 1.0 / 60.0


func _ready():
	physical_bone_simulator.physical_bones_start_simulation()
	physics_bones = self.physical_bone_simulator.get_children().filter(
		func(x): return x is PhysicalBone3D
	)
	physical_skeleton.skeleton_updated.connect(self._on_skeleton_updated)

func _physics_process(delta):
	_debug_ragdoll()
	self._delta = delta


func hookes_law(
	displacement: Vector3, current_velocity: Vector3, stiffness: float, damping: float
) -> Vector3:
	return (stiffness * displacement) - (damping * current_velocity)


func _on_skeleton_updated() -> void:
	for b in physics_bones:
		var target_transform: Transform3D = (
			target_skeleton.global_transform * target_skeleton.get_bone_global_pose(b.get_bone_id())
		)
		var current_transform: Transform3D = (
			physical_skeleton.global_transform * physical_skeleton.get_bone_global_pose(b.get_bone_id())
		)
		var rotation_difference: Basis = target_transform.basis * current_transform.basis.inverse()

		var position_difference: Vector3 = target_transform.origin - current_transform.origin

		if position_difference.length_squared() > 1.0:
			b.global_position = target_transform.origin
		else:
			var force: Vector3 = hookes_law(
				position_difference,
				b.linear_velocity,
				linear_spring_stiffness,
				linear_spring_damping
			)
			force = force.limit_length(max_linear_force)
			b.linear_velocity += (force * self._delta)

		var torque = hookes_law(
			rotation_difference.get_euler(),
			b.angular_velocity,
			angular_spring_stiffness,
			angular_spring_damping
		)
		torque = torque.limit_length(max_angular_force)

		b.angular_velocity += torque * self._delta


@onready var physical_bone_simulator_3d: PhysicalBoneSimulator3D = $"../../Character_Visual/Char_Physics/Skeleton3D/PhysicalBoneSimulator3D"
@onready var physical_bone_def_hips: PhysicalBone3D = $"../../Character_Visual/Char_Physics/Skeleton3D/PhysicalBoneSimulator3D/Physical Bone DEF-spine"
@onready var physical_bone_def_board: PhysicalBone3D = $"../../Character_Visual/Char_Physics/Skeleton3D/PhysicalBoneSimulator3D/Physical Bone DEF-board"
var active : bool = false
		
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
