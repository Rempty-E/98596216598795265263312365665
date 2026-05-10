extends Control

var is_visible: bool = false
var cell_width: float = 170.0
var zone_height: float = 576.0

func _draw():
	if is_visible:
		# Рисуем жирные линии, чтобы их точно было видно
		var color = Color(1, 1, 1, 0.3) # Белый с прозрачностью
		
		# Вертикальные линии
		for i in range(100):
			var x = i * cell_width
			draw_line(Vector2(x, 0), Vector2(x, zone_height), color, 2.0)
		
		# Горизонтальные линии (границы)
		draw_line(Vector2(0, 0), Vector2(20000, 0), color, 3.0)
		draw_line(Vector2(0, zone_height), Vector2(20000, zone_height), color, 3.0)

func toggle_grid(show: bool):
	is_visible = show
	queue_redraw()
