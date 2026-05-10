extends Node2D

@onready var building_manager = $BuildingManager
@onready var ground = $Ground
@onready var grid_preview = $GridPreview

const CELL_W = 170.0
const CELL_H = 192.0

var preview_sprite: Sprite2D
var current_building: BuildingData = null
var select_mode: bool = false:
	set(value):
		select_mode = value
		ground.visible = value
		if not value:
			grid_preview.hide_grid()
			if preview_sprite:
				preview_sprite.visible = false

var placeable: bool = false
var preview_tile: Vector2i

func _ready():
	preview_sprite = Sprite2D.new()
	add_child(preview_sprite)
	preview_sprite.modulate.a = 0.5
	ground.visible = false
	grid_preview.position = ground.map_to_local(Vector2i(0, 0))

func _physics_process(_delta):
	if select_mode and current_building:
		update_preview()

func update_preview():
	var mouse_pos = get_global_mouse_position()
	var local_mouse = ground.to_local(mouse_pos)
	var tile_pos = ground.local_to_map(local_mouse)
	tile_pos.y = 0

	if local_mouse.y < 0 or local_mouse.y > 576:
		grid_preview.hide_grid()
		preview_sprite.visible = false
		placeable = false
		return

	if preview_tile != tile_pos:
		preview_tile = tile_pos
		draw_preview_frame()

func draw_preview_frame():
	placeable = building_manager.can_place(preview_tile.x, current_building.width_in_cells)
	grid_preview.show_grid(preview_tile.x, current_building.width_in_cells, placeable)

	var cell_left = ground.map_to_local(preview_tile)
	var building_pixel_width = current_building.width_in_cells * CELL_W
	var tex_w = float(current_building.texture.get_width())
	var tex_h = float(current_building.texture.get_height())

	preview_sprite.centered = false
	preview_sprite.visible = true
	preview_sprite.texture = current_building.texture
	preview_sprite.position = Vector2(
		cell_left.x + (building_pixel_width - tex_w) / 2.0,
		cell_left.y + CELL_H - tex_h
	)

func place_actual_building():
	var new_sprite = Sprite2D.new()
	new_sprite.texture = current_building.texture
	new_sprite.centered = false
	add_child(new_sprite)

	var cell_left = ground.map_to_local(preview_tile)
	var building_pixel_width = current_building.width_in_cells * CELL_W
	var tex_w = float(current_building.texture.get_width())
	var tex_h = float(current_building.texture.get_height())

	new_sprite.position = Vector2(
		cell_left.x + (building_pixel_width - tex_w) / 2.0,
		cell_left.y + CELL_H - tex_h
	)

	building_manager.reserve_tiles(preview_tile.x, current_building.width_in_cells)

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_1:
			var res = load("res://res/house.tres")
			if res:
				current_building = res
				select_mode = true

		if event.keycode == KEY_ESCAPE:
			select_mode = false

	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT and select_mode and placeable:
			place_actual_building()
			select_mode = false
		elif event.button_index == MOUSE_BUTTON_RIGHT and select_mode:
			select_mode = false
