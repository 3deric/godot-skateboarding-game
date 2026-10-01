class_name MainGame
extends Node
# main entry point for the game
# based on https://www.youtube.com/watch?v=V4SO7foDoW4&list=WL&index=1

# player and level resources
const PLAYER_SCENE_UID : 	String = "uid://d2nejhxrsjjgk"
const LEVEL_SPLASH_UID : 	String = "uid://dri5ttie2jgqo"
const LEVEL_MENU_UID : 		String = "uid://4dexi0qui2ct"
const LEVEL_1_UID : 		String = "uid://bxeywehmeblyi"
const LEVEL_2_UID : 		String = "uid://duaw5sk1sesed"

# ui ressources
const MAIN_MENU_UID : 		String = "uid://ydofbmuhla2w"
const PAUSE_MENU_UID : 		String = "uid://3yuf44frpj4c"
const DEBUG_MENU_UID : 		String = "uid://1l4k8vpth51o"
const INGAME_HUD_UID :		String = "uid://f8h2uynd2b7n"

var main_menu : 			MainMenu = null
var pause_menu : 			PauseMenu = null
var ingame_hud : 			IngameHud = null
var _debug_menu : 			DebugMenu = null

# Game state machine
@onready var game_statemachine: Node = $Systems/Game_Statemachine

# Game world root nodes
@onready var level_root: 	Node3D = $World/LevelRoot
@onready var entity_root: 	Node3D = $World/EntityRoot
@onready var effect_root: 	Node3D = $World/EffectRoot

# UI Root nodes
@onready var hud_root: 		Control = $HudLayer/HudRoot
@onready var pause_root: 	Control = $PauseLayer/PauseRoot
@onready var transition_root:Control = $TransitionLayer/TransitionRoot
@onready var debug_root: 	Control = $DebugLayer/DebugRoot

# Game Variables
var player : 				Player = null
var _current_level : 		BaseLevel = null
var selected_level_uid :	String

func _ready() -> void:
	selected_level_uid = LEVEL_SPLASH_UID
	_init_player()
	_init_interface()
	game_statemachine.init()
	
func _init_player() -> void:
	var player_scene : PackedScene = ResourceLoader.load(PLAYER_SCENE_UID) as PackedScene
	if player_scene == null:
		push_error("Could not load player scene: " + PLAYER_SCENE_UID)
		return
	
	player = player_scene.instantiate() as Player
	if player == null:
		push_error("Loaded player scene does not extend Player or DNE: " + PLAYER_SCENE_UID)
		return
	entity_root.add_child(player)
	player.init()
	CustomizationManager.instance.customization_updated.emit() # load customization data
	
func _init_interface() -> void:
	var menu_scene : PackedScene = ResourceLoader.load(MAIN_MENU_UID) as PackedScene
	if menu_scene == null:
		push_error("Could not load menu scene: " + MAIN_MENU_UID)
		return
		
	main_menu = menu_scene.instantiate() as MainMenu
	if main_menu == null:
		push_error("Loaded menu scene does not extend Control or DNE: " + MAIN_MENU_UID)
		return
	
	hud_root.add_child(main_menu)
	main_menu.init(self)
	
	var pause_scene : PackedScene = ResourceLoader.load(PAUSE_MENU_UID) as PackedScene
	if pause_scene == null:
		push_error("Could not load pause scene: " + PAUSE_MENU_UID)
		return
		
	pause_menu = pause_scene.instantiate() as PauseMenu
	if pause_menu == null:
		push_error("Loaded pause scene does not extend Control or DNE: " + PAUSE_MENU_UID)
		return
	
	pause_root.add_child(pause_menu)
	pause_menu.init()
	
	var ingame_hud_scene : PackedScene = ResourceLoader.load(INGAME_HUD_UID) as PackedScene
	if ingame_hud_scene == null:
		push_error("Could not load ingame hud scene: " + INGAME_HUD_UID)
		return
		
	ingame_hud = ingame_hud_scene.instantiate() as IngameHud
	if ingame_hud == null:
		push_error("Loaded ingame hud scene does not extend Control or DNE: " + INGAME_HUD_UID)
		return
	
	hud_root.add_child(ingame_hud)
	ingame_hud.init()
	
	var debug_scene : PackedScene = ResourceLoader.load(DEBUG_MENU_UID) as PackedScene
	if debug_scene == null:
		push_error("Could not load debug scene: " + DEBUG_MENU_UID)
		return
		
	_debug_menu = debug_scene.instantiate() as DebugMenu
	if _debug_menu == null:
		push_error("Loaded debug scene does not extend Control or DNE: " + DEBUG_MENU_UID)
		return
	
	debug_root.add_child(_debug_menu)
	_debug_menu.init()
		
func load_level(level_scene : String) -> void:
	_deferred_load_level(level_scene)
	
func _deferred_load_level(level_scene_uid : String) -> void:
	if player != null:
		player.set_is_playing(false)
		
	if _current_level != null:
		_current_level.queue_free()
		_current_level = null
		
	# Allow the old level to finish freeing befor adding a new one
	await get_tree().process_frame
	
	var new_level_packed : PackedScene =\
		ResourceLoader.load(level_scene_uid, "PackedScene") as PackedScene
	if new_level_packed == null:
		push_error("Could not load level as packed scene: " + level_scene_uid)
		return
	
	_current_level = new_level_packed.instantiate() as BaseLevel
	if _current_level == null:
		push_error("Loaded level scene does not extend BaseLevel or DNE: " + level_scene_uid)
		return
	
	level_root.add_child(_current_level)
	
	await get_tree().process_frame
	_place_player_at_level_spawn()
	#_setup_level_camera()

func _place_player_at_level_spawn() -> void:
	player.init_level(_current_level.get_player_spawn(), _current_level.get_is_playing())
