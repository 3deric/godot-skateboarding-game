class_name InterpolatedSkeletonModifier3D extends SkeletonModifier3D

@export_range(0.0, 1.0) var physics_interpolation: float = 0.5

@export var physics_skeleton: Skeleton3D
@export var animated_skeleton: Skeleton3D


func _ready() -> void:
	self.physics_skeleton.skeleton_updated.connect(self._on_physics_skeleton_updated)


func _on_physics_skeleton_updated():
	for i in range(0, self.get_skeleton().get_bone_count()):
		var animated_transform: Transform3D = (animated_skeleton.global_transform * animated_skeleton.get_bone_global_pose(i))
		var physics_transform: Transform3D = (physics_skeleton.global_transform * physics_skeleton.get_bone_global_pose(i))
		self.get_skeleton().set_bone_global_pose(i, global_transform.affine_inverse()* (animated_transform.interpolate_with(physics_transform,physics_interpolation)))
