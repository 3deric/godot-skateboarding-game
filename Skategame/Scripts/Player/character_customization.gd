class_name CharacterCustomization
extends Node

@onready var body_mesh : MeshInstance3D = $"../../Character_Visual/Char_Interpolated/Skeleton3D/char_body"
@onready var top_mesh : MeshInstance3D = $"../../Character_Visual/Char_Interpolated/Skeleton3D/char_top"
@onready var bottom_mesh : MeshInstance3D = $"../../Character_Visual/Char_Interpolated/Skeleton3D/char_bottom"
@onready var shoes_mesh : MeshInstance3D = $"../../Character_Visual/Char_Interpolated/Skeleton3D/char_shoes"
@onready var board_mesh : MeshInstance3D = $"../../Character_Visual/Char_Interpolated/Skeleton3D/char_board"
@onready var hair_mesh : MeshInstance3D = $"../../Character_Visual/Char_Interpolated/Skeleton3D/char_hair"
@onready var helmet_mesh : MeshInstance3D =  $"../../Character_Visual/Char_Interpolated/Skeleton3D/char_helmet"
@onready var glasses_mesh : MeshInstance3D = $"../../Character_Visual/Char_Interpolated/Skeleton3D/char_headwear"
@onready var char_skeleton: Node3D = $"../../Character_Visual/Char_Interpolated"
const BODY_MALE : Material = preload("res://Assets/Characters/Materials/M_char_male_body_colorable.tres")
const BODY_FEMALE : Material = preload("res://Assets/Characters/Materials/M_char_female_body_colorable.tres")


func _ready() -> void:
	_init()
	_connect_signals()
	_update_from_data()

	
func _init() -> void:
	pass


func _connect_signals() -> void:
	if not CustomizationManager.instance.color_updated.is_connected(_on_color_updated):
		CustomizationManager.instance.color_updated.connect(_on_color_updated)
	if not CustomizationManager.instance.decal_updated.is_connected(_on_decal_updated):
		CustomizationManager.instance.decal_updated.connect(_on_decal_updated)
	if not CustomizationManager.instance.customization_updated.is_connected(_on_customization_updated):
		CustomizationManager.instance.customization_updated.connect(_on_customization_updated)
	if not CustomizationManager.instance.float_updated.is_connected(_on_float_updated):
		CustomizationManager.instance.float_updated.connect(_on_float_updated)
	if not CustomizationManager.instance.mesh_updated.is_connected(_on_mesh_updated):
		CustomizationManager.instance.mesh_updated.connect(_on_mesh_updated)


func _on_color_updated(part: CharacterData.CharacterPart, sub: String, color :Color) -> void:
	match part:
		CharacterData.CharacterPart.Body:
			match sub:
				'eyes':
					_update_body_eyes_color(color)
		CharacterData.CharacterPart.Hair:
			match sub:
				'color':
					_update_hair_color(color)
		CharacterData.CharacterPart.Top:
			match sub:
				'base':
					_update_top_base_color(color)
				'accent':
					_update_top_accent_color(color)
				'detail':
					_update_top_detail_color(color)
		CharacterData.CharacterPart.Bottom:
			match sub:
				'base':
					_update_bottom_base_color(color)
				'accent':
					_update_bottom_accent_color(color)
				'detail':
					_update_bottom_detail_color(color)
		CharacterData.CharacterPart.Shoes:
			match sub:
				'base':
					_update_shoes_base_color(color)
				'accent':
					_update_shoes_accent_color(color)
				'detail':
					_update_shoes_detail_color(color)
		CharacterData.CharacterPart.Board:
			match sub:
				'wheels':
					_update_board_wheels_color(color)
				'accent':
					_update_board_accent_color(color)
				'metal':
					_update_board_metal_color(color)


func _on_mesh_updated(part: CharacterData.CharacterPart, index : int) -> void:
	match part:
		CharacterData.CharacterPart.Hair:
			_update_hair_mesh(index)
		CharacterData.CharacterPart.Top:
			_update_top_mesh(index)
		CharacterData.CharacterPart.Bottom:
			_update_bottom_mesh(index)
		CharacterData.CharacterPart.Shoes:
			_update_shoes_mesh(index)
		CharacterData.CharacterPart.Helmet:
			_update_helmet_mesh(index)
		CharacterData.CharacterPart.Glasses:
			_update_glasses_mesh(index)


func _on_decal_updated(part: CharacterData.CharacterPart, index :int) -> void:
	match part:
		CharacterData.CharacterPart.Top:
			_update_top_decal(index)
		CharacterData.CharacterPart.Board:
			_update_board_decal(index)


func _on_float_updated(part: CharacterData.CharacterPart, sub: String, value: float) -> void:
	match part:
		CharacterData.CharacterPart.Body:
			match sub:
				'skin_color':
					_update_body_skin_color(value)
				'size':
					char_skeleton.scale = Vector3(value, value, value)
				'gender':
					_update_gender(value)
					_update_top_gender(value)
					_update_bottom_gender(value)
					

func _on_customization_updated() ->void:
	_update_from_data()

	
func _update_from_data() -> void:
	var data = CustomizationManager.instance.character_data
	_update_top_base_color(data.top_base_color)
	_update_top_accent_color(data.top_accent_color)
	_update_top_detail_color(data.top_detail_color)
	_update_bottom_base_color(data.bottom_base_color)
	_update_bottom_accent_color(data.bottom_accent_color)
	_update_bottom_detail_color(data.bottom_detail_color)
	_update_shoes_base_color(data.shoes_base_color)
	_update_shoes_accent_color(data.shoes_accent_color)
	_update_shoes_detail_color(data.shoes_detail_color)
	_update_board_wheels_color(data.board_wheels_color)
	_update_board_accent_color(data.board_accent_color)
	_update_board_metal_color(data.board_metal_color)
	_update_board_decal(data.board_decal)
	_update_top_decal(data.top_decal)
	_update_hair_color(data.hair_color)
	_update_body_skin_color(data.skin_color)
	_update_body_eyes_color(data.eye_color)
	_update_hair_mesh(data.hair_mesh)
	_update_top_mesh(data.top_mesh)
	_update_bottom_mesh(data.bottom_mesh)
	_update_shoes_mesh(data.shoes_mesh)
	_update_gender(data.gender)
	_update_top_gender(data.gender)
	_update_bottom_gender(data.gender)
	_update_helmet_mesh(data.helmet_mesh)
	_update_glasses_mesh(data.glasses_mesh)
#Top

func _update_top_base_color(color: Color) -> void:
	_update_color(top_mesh, "base_color", color)
	
	
func _update_top_accent_color(color: Color) -> void:
	_update_color(top_mesh, "accent_color", color)
	

func _update_top_detail_color(color: Color) -> void:
	_update_color(top_mesh, "detail_color", color)
	
#Bottom

func _update_bottom_base_color(color: Color) -> void:
	_update_color(bottom_mesh, "base_color", color)
	
	
func _update_bottom_accent_color(color: Color) -> void:
	_update_color(bottom_mesh, "accent_color", color)
	

func _update_bottom_detail_color(color: Color) -> void:
	_update_color(bottom_mesh, "detail_color", color)
	

#Shoes

func _update_shoes_base_color(color: Color) -> void:
	_update_color(shoes_mesh, "base_color", color)
	
	
func _update_shoes_accent_color(color: Color) -> void:
	_update_color(shoes_mesh, "accent_color", color)
	

func _update_shoes_detail_color(color: Color) -> void:
	_update_color(shoes_mesh, "detail_color", color)
	
	
func _update_board_wheels_color(color: Color) -> void:
	_update_color(board_mesh, "wheels_color", color)


func _update_board_accent_color(color: Color) -> void:
	_update_color(board_mesh, "accent_color", color)


func _update_board_metal_color(color: Color) -> void:
	_update_color(board_mesh, "metal_color", color)


func _update_board_decal(index: int) -> void:
	_update_decal(board_mesh, "decal", CustomizationManager.instance.board_decals[index])


func _update_top_decal(index: int) -> void:
	_update_decal(top_mesh, "decal", CustomizationManager.instance.top_decals[index])
	

func _update_body_eyes_color(color: Color) -> void:
	_update_color(body_mesh, "eyes", color)


func _update_body_skin_color(value: float) -> void:
	_update_float(body_mesh, "skin_color", value)


func _update_hair_color(color: Color) -> void:
	_update_color(hair_mesh, "hair_color", color)

	
func _update_hair_mesh(index :int) -> void:
	if index == 0:
		hair_mesh.hide()
	else:
		hair_mesh.show()
		hair_mesh.mesh = CustomizationManager.instance.hair_meshes[index -1]
		
		
func _update_top_mesh(index :int) -> void:
	if index == 0:
		top_mesh.hide()
	else:
		top_mesh.show()
		top_mesh.mesh = CustomizationManager.instance.top_meshes[index -1]
	
		
func _update_bottom_mesh(index :int) -> void:
	if index == 0:
		bottom_mesh.hide()
	else:
		bottom_mesh.show()
		bottom_mesh.mesh = CustomizationManager.instance.bottom_meshes[index -1]
	
		
func _update_shoes_mesh(index :int) -> void:
	if index == 0:
		shoes_mesh.hide()
		body_mesh.set_blend_shape_value(1,0.0)
	else:
		shoes_mesh.show()
		shoes_mesh.mesh = CustomizationManager.instance.shoe_meshes[index -1]
		body_mesh.set_blend_shape_value(1,1.0)

func _update_helmet_mesh(index :int) -> void:
	if index == 0:
		helmet_mesh.hide()
	else:
		helmet_mesh.show()
		helmet_mesh.mesh = CustomizationManager.instance.helmet_meshes[index -1]
		
func _update_glasses_mesh(index :int) -> void:
	if index == 0:
		glasses_mesh.hide()
	else:
		glasses_mesh.show()
		glasses_mesh.mesh = CustomizationManager.instance.glasses_meshes[index -1]
		
		
func _update_gender(value : float) -> void:
	body_mesh.set_blend_shape_value(0, value)
	if value > 0.5:
		body_mesh.set_surface_override_material(0, BODY_FEMALE)
	else:
		body_mesh.set_surface_override_material(0, BODY_MALE)
	

func _update_top_gender(value : float) -> void:
	top_mesh.set_blend_shape_value(0, value)
	

func _update_bottom_gender(value : float) -> void:
	bottom_mesh.set_blend_shape_value(0, value)
	

func _update_color(_mesh : MeshInstance3D, _param : String, _color : Color) -> void:
	if not _mesh:
		push_error(str(_mesh)  + " is not assigned")
		return
	var material = _mesh.get_active_material(0)
	if not material:
		push_error("No material found on " + str(_mesh))
		return
	if material is ShaderMaterial:
		material.set_shader_parameter(_param, _color)
	else:
		push_error("Unsupported material type: " + str(material.get_class()))


func _update_float(_mesh : MeshInstance3D, _param : String, _value: float) -> void:
	if not _mesh:
		push_error(str(_mesh)  + " is not assigned")
		return
	var material = _mesh.get_active_material(0)
	if not material:
		push_error("No material found on " + str(_mesh))
		return
	if material is ShaderMaterial:
		material.set_shader_parameter(_param, _value)
	else:
		push_error("Unsupported material type: " + str(material.get_class()))
		

func _update_decal(_mesh : MeshInstance3D, _param : String, _decal: CompressedTexture2D) -> void:
	if not _mesh:
		push_error(str(_mesh)  + " is not assigned")
		return
	var material = _mesh.get_active_material(0)
	if not material:
		push_error("No material found on " + str(_mesh))
		return
	if material is ShaderMaterial:
		material.set_shader_parameter(_param, _decal)
	else:
		push_error("Unsupported material type: " + str(material.get_class()))
