extends Node2D

# Список координат X, которые уже заняты
var used_tiles_x = [] 

# Проверяем, свободен ли диапазон клеток
func can_place(start_x: int, width: int) -> bool:
	for i in range(width):
		if (start_x + i) in used_tiles_x:
			return false
	return true

# Занимаем клетки
func reserve_tiles(start_x: int, width: int):
	for i in range(width):
		var tile_x = start_x + i
		if tile_x not in used_tiles_x:
			used_tiles_x.append(tile_x)

# Очистить клетки (если здание снесут)
func free_tiles(start_x: int, width: int):
	for i in range(width):
		used_tiles_x.erase(start_x + i)
