class_name LibHelpers
extends RefCounted


static func raycast(_from: Vector3, _dir: Vector3, _len: float, _player: CharacterBody3D):
	var _spaceState : PhysicsDirectSpaceState3D = _player.get_world_3d().direct_space_state
	var _query : PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(_from, _from + _dir * _len)
	_query.exclude = [_player]
	var _col = _spaceState.intersect_ray(_query)
	return _col
	
static func is_path_closed(_path: Path3D)->bool:
	var _curve = _path.curve
	if _curve == null:
		return false	
	return _curve.closed

static func forward_velocity(_vel : Vector3, _up_direction: Vector3) -> Vector3:
	return _vel.slide(_up_direction)
	
static func horizontal_velocity(_vel : Vector3) -> Vector3:
	return _vel.slide(Vector3.UP)
	
static func get_path_position(_path: Path3D, _offset : float):
	var _curve : Curve3D = _path.curve
	return _path.global_transform * _curve.sample_baked(_offset, true)
	
static func get_path_upvector(_path: Path3D, _offset: float):
	var _curve : Curve3D = _path.curve
	return _curve.sample_baked_up_vector(_offset, true)

static func get_path_tangent(_path: Path3D, _offset: float): #returns the curve tangent
	if !_path:
		return Vector3.ZERO
	var _lastOffset : float
	var _lastCurvePos : Vector3
	var _curvePos : Vector3 = _path.curve.sample_baked(_offset, true)
	var _curveLength : float = _path.curve.get_baked_length()
	var _tangent : Vector3
	if _offset + 0.025 >= _curveLength:
		_lastOffset = _offset - 0.025 
		_lastCurvePos = _path.curve.sample_baked(_lastOffset, true)
		_tangent = (_lastCurvePos - _curvePos).normalized()
	else:
		_lastOffset = _offset + 0.025
		_lastCurvePos = _path.curve.sample_baked(_lastOffset, true)
		_tangent = (_curvePos - _lastCurvePos).normalized()
	var _local_tangent = (_tangent * Vector3(1,0,1)).normalized()
	return (_path.global_transform.basis * _local_tangent).normalized()
		
static func get_path_dir(_tangent: Vector3, _vel: Vector3, _treshold): #direction along curve based on start pos
	var _pathDir : float = _tangent.dot(_vel.normalized())
	if(_pathDir > _treshold):
		return  -1
	if(_pathDir < -_treshold):
		return 1
	else:
		return 0

static func get_closest_curve_offset(_path: Path3D, _pos: Vector3):
	var _curve: Curve3D = _path.curve
	var _pathTransform: Transform3D = _path.global_transform
	var _localPos: Vector3 = _pos * _pathTransform
	var _offset: float = _curve.get_closest_offset(_localPos)
	return _offset
		
static func get_position_on_curve(_path: Path3D, _offset):
	var _curve: Curve3D = _path.curve
	var _curvePos: Vector3 = _curve.sample_baked(_offset, true)
	return _curvePos
	
static func get_stick_curve(_path: Path3D,_offset: float, _threshold):
	if _path == null:
		return false
	var _curve: Curve3D = _path.curve
	if(_offset <= _threshold or _offset >= _curve.get_baked_length() -_threshold):
		return false
	else:
		return true

static func wrap_curve(_path : Path3D, _offset : float) -> float:
	var _curve : Curve3D = _path.curve
	_offset = wrapf(_offset, 0.0, _curve.get_baked_length())
	return _offset

static func pipe_snap_up_dir(_curveTangent : Vector3, _last_up_dir, _pipe_snap_flip : bool) -> Vector3: #calculate upvector while snapped to a pipe
	var _newUpDir : Vector3 = Vector3.UP.cross(_curveTangent)
	if _pipe_snap_flip:
		_newUpDir *= -1
	if(_newUpDir != Vector3.ZERO):
		return _newUpDir
	else:
		return _last_up_dir
			
static func limit_velocity(_vel : Vector3, _max_vel : float):
	if _vel.length() > _max_vel:
		return _vel.normalized() * _max_vel
		
static func kill_orthogonal_velocity(_xForm : Transform3D, _vel: Vector3) -> Vector3: 	#remove orthogonal component of velocity
	var _basis = _xForm.basis
	var _fwdVel = _basis.z * _vel.dot(_basis.z)
	var _velocity = _fwdVel + (_basis.x * _vel.dot(_basis.x)) * 0.1 + _basis.y * _vel.dot(_basis.y)
	return _velocity

static func kill_pipe_orthogonal_velocity(_vel: Vector3, _tangent: Vector3):
	var _newVel : Vector3 = _vel.dot(_tangent) * _tangent
	_newVel.y = _vel.y
	var _velocity : Vector3 = _newVel
	return _velocity

static func align(_xForm, _newUp):
	var current_up = _xForm.basis.y
	var target_up = _newUp.normalized()
	if current_up.dot(target_up) > 0.999:
		return _xForm
	var rotation_axis = current_up.cross(target_up)
	if rotation_axis.length() < 0.001:
		rotation_axis = Vector3(1, 0, 0)
	var rotation_angle = current_up.angle_to(target_up)
	var rotation_quat = Quaternion(rotation_axis.normalized(), rotation_angle)
	_xForm.basis = Basis(rotation_quat) * _xForm.basis
	_xForm.basis = _xForm.basis.orthonormalized()	
	return _xForm
	
static func get_closest_path(area: Area3D, pos: Vector3) -> Path3D:
	var _path : Path3D = null
	var _dist :float = 1e12
	for body: CSGPolygon3D in area.get_overlapping_bodies():
		if body.is_in_group("rampRail"):
			var _curr_path: Path3D = body.get_node(body.get_path_node())
			var _curr_path_offset : float = LibHelpers.get_closest_curve_offset(_curr_path, pos)
			var _curr_path_pos : Vector3 = LibHelpers.get_position_on_curve(_curr_path, _curr_path_offset)
			var _curr_path_dist : float = pos.distance_to(_curr_path_pos)
			if _curr_path_dist < _dist:
				_dist = _curr_path_dist
				_path = _curr_path
	return _path

static func start_grind(vel: Vector3, path: Path3D, offset : float) -> Dictionary:
	if !path:
		return {
		"valid": false
		}
	var _tan : Vector3 = LibHelpers.get_path_tangent(path, offset)
	if _tan == Vector3.ZERO:
		return {"valid": false}
	var _dir : int = LibHelpers.get_path_dir(_tan, vel, 0.25)
	if _dir == 0:
		return {"valid": false}
	var _path_vel : float = vel.project(_tan).length() * _dir
	return {
		"valid": true,
		"vel": _path_vel,
		"dir": _dir,
		"tan": _tan
	}

static func start_lip(xform: Transform3D, vel: Vector3, path: Path3D, offset: float) -> Dictionary:	
	if !path:
		return {
		"valid": false,
	}
	var _tan : Vector3 = LibHelpers.get_path_tangent(path, offset)
	var _path_global_transform = path.global_transform
	var _curve = path.curve
	var _global_path_pos = LibHelpers.get_path_position(path, offset)
	var _to_player = (xform.origin - _global_path_pos)
	var _to_player_horizontal = _to_player.slide(Vector3.UP).normalized()
	var _perp = _tan.cross(Vector3.UP).normalized()
	var _dot_to_perp = _to_player_horizontal.dot(_perp)
	var _dir = _perp if _dot_to_perp > 0 else -_perp
	if _to_player_horizontal.length_squared() < 0.01 or abs(_dot_to_perp) < 0.1:
		var _vel_horizontal = vel.slide(Vector3.UP).normalized()
		if _vel_horizontal.length_squared() > 0.01:
			var _vel_on_perp = _vel_horizontal.dot(_perp)
			_dir = _perp if _vel_on_perp > 0 else -_perp
	
	return {
		"valid": true,
		"tan": _tan,
		"dir" : _dir.normalized() * -1,
		"up": _curve.sample_baked_up_vector(offset),
		"vel": vel,
		"pos": _global_path_pos
	}

static func start_pipesnap(xform: Transform3D, vel: Vector3, path: Path3D, offset: float) -> Dictionary:
	var _tan : Vector3 = LibHelpers.get_path_tangent(path, offset)
	var _dir : Vector3 = _tan.cross(Vector3.UP)
	var _flip : bool = xform.basis.y.dot(_dir) > 0
	var _path_dir : int = LibHelpers.get_path_dir(_tan, vel, 0.1)
	var _path_vel : float = vel.project(_tan * Vector3(1,0,1)).length() * _path_dir
	var _stick : bool = LibHelpers.get_stick_curve(path, offset, GlobalSettings.STICK_CURVE_THRESHOLD)
	return {
		"valid": _stick,
		"tan": _tan,
		"dir": _path_dir,
		"vel": _path_vel,
		"flip": _flip
	}
	
static func landed_on_feet(_ray_down : Dictionary, _up_direction : Vector3, _threshold : float) -> Dictionary:
	if _up_direction.dot(Vector3.UP) > 0.05:
		return {
			"valid": true
		}
	if _ray_down:
		var _dot : float = _up_direction.dot(_ray_down.normal)
		return {
			"valid": _dot >= _threshold,
			"dot": _dot
			} 			
	return {
			"valid": true,
			}
			
static func landed_perpendicular(_fwd_vel : Vector3, _fwd_dir : Vector3 , _threshold : float) -> Dictionary:
	var _dot : float = abs(_fwd_vel.normalized().dot(_fwd_dir))
	return {
		"valid": _dot >= _threshold,
		"dot": _dot
		}
