@tool
extends Node2D

const CELL_W = 170.0
const CELL_H = 192.0
const GRID_COLS = 12

var highlight_x: int = 0
var highlight_width: int = 1
var is_placeable: bool = true
var is_visible_grid: bool = false

func show_grid(tile_x: int, width: int, placeable: bool):
	highlight_x = tile_x
	highlight_width = width
	is_placeable = placeable
	is_visible_grid = true
	queue_redraw()

func hide_grid():
	is_visible_grid = false
	queue_redraw()

func _draw():
	# В редакторе всегда рисуем сетку чтобы было видно где она
	if not is_visible_grid and not Engine.is_editor_hint():
		return

	var grid_color = Color(1.0, 1.0, 1.0, 0.12)
	var grid_fill  = Color(1.0, 1.0, 1.0, 0.04)

	for col in range(GRID_COLS):
		var cell_x = col * CELL_W
		var rect = Rect2(cell_x, 0, CELL_W, CELL_H)
		draw_rect(rect, grid_fill)
		draw_rect(rect, grid_color, false, 1.0)

	# Подсветку рисуем только во время игры
	if not Engine.is_editor_hint() and is_visible_grid:
		var fill_color   = Color(0.2, 1.0, 0.2, 0.25) if is_placeable else Color(1.0, 0.2, 0.2, 0.35)
		var border_color = Color(0.2, 1.0, 0.2, 0.9)  if is_placeable else Color(1.0, 0.2, 0.2, 0.9)

		for i in range(highlight_width):
			var cell_x = (highlight_x + i) * CELL_W
			var rect = Rect2(cell_x, 0, CELL_W, CELL_H)
			draw_rect(rect, fill_color)
			draw_rect(rect, border_color, false, 2.0)
