extends Node2D

@onready var placement_manager = $PlacementManager
@onready var camera_controller = $Camera2D

var building_types: Array[BuildingData] = []
var selected_building_data: BuildingData = null

var resources = {
	"gold": 0,
	"food": 0,
	"population": 0
}

func _ready():
	load_buildings_from_folder()
	
	if not building_types.is_empty():
		selected_building_data = building_types[0]
	
	placement_manager.resources_changed.connect(_on_resource_added)
	
	setup_camera()

# ---------------------------
# КАМЕРА
# ---------------------------

func setup_camera():
	var limit_px = placement_manager.map_half_width * placement_manager.cell_size
	var grid_y = placement_manager.global_position.y
	
	camera_controller.setup_limits(
		-limit_px,
		limit_px,
		grid_y
	)

# ---------------------------
# INPUT
# ---------------------------

func _input(event):
	handle_build_selection(event)
	handle_building_input(event)

func handle_build_selection(event):
	if event is InputEventKey and event.pressed:
		var index = int(event.keycode) - int(KEY_1)
		
		if index >= 0 and index < building_types.size():
			selected_building_data = building_types[index]

func handle_building_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				placement_manager.start_drag(selected_building_data)
			elif placement_manager.is_building_drag:
				placement_manager.request_place()
		
		if event.button_index == MOUSE_BUTTON_RIGHT:
			placement_manager.cancel_drag()
	
	if event.is_action_pressed("ui_cancel"):
		placement_manager.cancel_drag()

# ---------------------------
# РЕСУРСЫ
# ---------------------------

func _on_resource_added(type, amount):
	resources[type] += amount
	update_ui()

func update_ui():
	if has_node("GameUI"):
		$GameUI.update_resources(
			resources["gold"],
			resources["food"],
			resources["population"]
		)

# ---------------------------
# ЗАГРУЗКА
# ---------------------------

func load_buildings_from_folder():
	building_types.clear()
	
	var path = "res://res/"
	var dir = DirAccess.open(path)
	if not dir:
		return
	
	dir.list_dir_begin()
	var file = dir.get_next()
	
	while file != "":
		if not dir.current_is_dir() and file.ends_with(".tres"):
			var res = load(path + file)
			if res is BuildingData:
				building_types.append(res)
		
		file = dir.get_next()
