extends Node2D

@export var grid_layer: TileMapLayer
@export var building_scene: PackedScene # Сюда перетащи сцену здания (например, Hospital.tscn)
@export var preview_texture: Texture2D  # Текстура для превью

var preview_sprite: Sprite2D
var current_grid_pos: Vector2i
var occupied_cells: Dictionary = {} # Словарь для хранения занятых ячеек

func _ready():
	# Создаем спрайт для превью программно (или можешь добавить его в сцену вручную)
	preview_sprite = Sprite2D.new()
	preview_sprite.texture = preview_texture
	preview_sprite.modulate = Color(1, 1, 1, 0.5) # Делаем полупрозрачным
	# Если спрайты зданий строятся от низа (offset), настрой это здесь
	# preview_sprite.centered = false 
	add_child(preview_sprite)

func _process(_delta):
	# 1. Получаем позицию мыши в мире
	var mouse_pos = get_global_mouse_position()
	
	# 2. Переводим позицию мыши в координаты сетки (например: 0,1 или 2,3)
	current_grid_pos = grid_layer.local_to_map(mouse_pos)
	
	# 3. Примагничиваем превью к центру текущей ячейки
	var snapped_pos = grid_layer.map_to_local(current_grid_pos)
	preview_sprite.global_position = snapped_pos
	
	# 4. Подсвечиваем красным, если ячейка занята
	if occupied_cells.has(current_grid_pos):
		preview_sprite.modulate = Color(1, 0, 0, 0.5) # Красный (нельзя строить)
	else:
		preview_sprite.modulate = Color(0, 1, 0, 0.5) # Зеленый (можно строить)

func _unhandled_input(event):
	# Если нажали левую кнопку мыши и ячейка свободна
	if event.is_action_pressed("left_click") and not occupied_cells.has(current_grid_pos):
		build_structure(current_grid_pos)

func build_structure(grid_pos: Vector2i):
	# 1. Отмечаем ячейку как занятую
	occupied_cells[grid_pos] = true
	
	# 2. Создаем здание
	var building_instance = building_scene.instantiate()
	
	# Важно: добавляем здание как дочерний элемент на тот же уровень (или в спец. узел для Y-Sort)
	# чтобы они правильно сортировались
	add_child(building_instance)
	
	# 3. Размещаем здание точно по сетке
	building_instance.global_position = grid_layer.map_to_local(grid_pos)
	
	print("Здание построено в координатах сетки: ", grid_pos)
