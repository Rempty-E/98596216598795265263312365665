@tool
extends Node2D

# =========================================================
# СИГНАЛЫ
# =========================================================
signal resources_changed(key: String, value: int)

# =========================================================
# НАСТРОЙКИ
# =========================================================
@export var cell_size: int = 170
@export var cell_height: int = 192
@export var map_half_width: int = 100

@export var tex_cell_gray: Texture2D : set = _set_gray_texture
@export var tex_cell_green: Texture2D
@export var tex_cell_red: Texture2D

# =========================================================
# КОНСТАНТЫ
# =========================================================
const INVALID_INDEX := -999999

# =========================================================
# ВНУТРЕННЕЕ СОСТОЯНИЕ
# =========================================================

# хранение занятых клеток (лучше чем массив)
var occupied := {}

# ghost / preview
var ghost_building: Sprite2D = null
var highlight_sprite: Sprite2D

var selected_building_data: BuildingData = null
var current_index: int = INVALID_INDEX
var is_building_drag: bool = false

# контейнер сетки
var grid_container: Node2D


# =========================================================
# LIFECYCLE
# =========================================================

func _ready():
	if Engine.is_editor_hint():
		return
	
	_setup_runtime()

func _enter_tree():
	if Engine.is_editor_hint():
		_setup_editor()

func _notification(what):
	if what == NOTIFICATION_TRANSFORM_CHANGED and Engine.is_editor_hint():
		# двигаешь ноду — сетка остаётся на месте локально
		# ничего пересоздавать не нужно
		pass


# =========================================================
# SETUP
# =========================================================

func _setup_runtime():
	_create_grid_container()
	_create_highlight()
	_build_visual_grid()

func _setup_editor():
	_create_grid_container()
	_build_visual_grid()


func _create_grid_container():
	if grid_container:
		return
	
	grid_container = Node2D.new()
	grid_container.name = "Grid"
	add_child(grid_container)


func _create_highlight():
	if highlight_sprite:
		return
	
	highlight_sprite = Sprite2D.new()
	highlight_sprite.name = "Highlight"
	highlight_sprite.centered = false
	highlight_sprite.z_index = 10
	highlight_sprite.visible = false
	
	add_child(highlight_sprite)


# =========================================================
# СЕТКА (ВИЗУАЛ)
# =========================================================

func _build_visual_grid():
	if not tex_cell_gray:
		return
	
	if grid_container.get_child_count() > 0:
		return
	
	var scale_x = float(cell_size) / tex_cell_gray.get_width()
	var scale_y = float(cell_height) / tex_cell_gray.get_height()
	
	for x in range(-map_half_width, map_half_width):
		var cell := Sprite2D.new()
		cell.texture = tex_cell_gray
		cell.centered = false
		cell.position = Vector2(x * cell_size, 0)
		cell.scale = Vector2(scale_x, scale_y)
		
		grid_container.add_child(cell)


func _set_gray_texture(value):
	tex_cell_gray = value
	
	if Engine.is_editor_hint():
		_rebuild_grid_editor()


func _rebuild_grid_editor():
	if not grid_container:
		return
	
	for c in grid_container.get_children():
		c.queue_free()
	
	_build_visual_grid()


# =========================================================
# INPUT / PROCESS
# =========================================================

func _process(_delta):
	if Engine.is_editor_hint():
		return
	
	if is_building_drag:
		_update_ghost()


# =========================================================
# BUILDING FLOW
# =========================================================

func start_drag(data: BuildingData):
	if not data:
		return
	
	selected_building_data = data
	is_building_drag = true
	current_index = INVALID_INDEX
	
	_create_ghost(data)


func cancel_drag():
	is_building_drag = false
	current_index = INVALID_INDEX
	
	if ghost_building:
		ghost_building.queue_free()
		ghost_building = null
	
	highlight_sprite.visible = false


func request_place():
	if not is_building_drag:
		return
	
	if current_index == INVALID_INDEX:
		cancel_drag()
		return
	
	if not _can_place(current_index):
		cancel_drag()
		return
	
	_place_building(current_index)
	cancel_drag()


# =========================================================
# GHOST
# =========================================================

func _create_ghost(data: BuildingData):
	if ghost_building:
		ghost_building.queue_free()
	
	ghost_building = Sprite2D.new()
	ghost_building.texture = data.texture
	ghost_building.centered = false
	ghost_building.modulate = Color(1, 1, 1, 0.5)
	ghost_building.z_index = 100
	
	add_child(ghost_building)


func _update_ghost():
	if not ghost_building or not selected_building_data:
		_hide_ghost()
		return
	
	var index := _calculate_index()
	
	if index == INVALID_INDEX:
		_hide_ghost()
		return
	
	current_index = index
	
	_apply_ghost_visual(index)


func _hide_ghost():
	if ghost_building:
		ghost_building.visible = false
	
	highlight_sprite.visible = false
	current_index = INVALID_INDEX


func _apply_ghost_visual(index: int):
	var width = selected_building_data.width_in_cells
	
	ghost_building.visible = true
	ghost_building.position = Vector2(index * cell_size, 0)
	
	# highlight
	highlight_sprite.visible = true
	highlight_sprite.position = ghost_building.position
	
	# масштаб под ширину здания
	var base_w = tex_cell_gray.get_width()
	var base_h = tex_cell_gray.get_height()
	
	highlight_sprite.scale = Vector2(
		width * (float(cell_size) / base_w),
		float(cell_height) / base_h
	)
	
	highlight_sprite.texture = tex_cell_green if _can_place(index) else tex_cell_red


# =========================================================
# ЛОГИКА СЕТКИ
# =========================================================

func _calculate_index() -> int:
	var local_mouse = to_local(get_global_mouse_position())
	
	if local_mouse.y < 0 or local_mouse.y > cell_height:
		return INVALID_INDEX
	
	var raw = floor(local_mouse.x / cell_size)
	var width = selected_building_data.width_in_cells
	
	return clamp(raw, -map_half_width, map_half_width - width)


func _can_place(index: int) -> bool:
	var width = selected_building_data.width_in_cells
	
	for i in range(width):
		if occupied.has(index + i):
			return false
	
	return true


# =========================================================
# РАЗМЕЩЕНИЕ
# =========================================================

func _place_building(index: int):
	var width = selected_building_data.width_in_cells
	
	# отмечаем занятость
	for i in range(width):
		occupied[index + i] = true
	
	# создаём визуал
	var sprite := Sprite2D.new()
	sprite.texture = selected_building_data.texture
	sprite.centered = false
	
	var scale_x = (cell_size * width) / sprite.texture.get_width()
	var scale_y = cell_height / sprite.texture.get_height()
	sprite.scale = Vector2(scale_x, scale_y)
	
	var container := Node2D.new()
	container.position = Vector2(index * cell_size, 0)
	container.add_child(sprite)
	
	add_child(container)
	
	# сигнал
	resources_changed.emit("population", 1)
