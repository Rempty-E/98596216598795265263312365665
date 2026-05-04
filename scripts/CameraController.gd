extends Camera2D

# Настройки
@export var speed: float = 1200.0
@export var zoom_speed: float = 0.1
@export var min_zoom: float = 1.0  # Чтобы не было полос сверху
@export var max_zoom: float = 3.0
@export var zoom_smoothing: float = 15.0

# Координаты
var limit_min_x: float = -10000.0
var limit_max_x: float = 10000.0
var ground_y: float = 760.0  # Линия земли в твоем проекте

var target_position_x: float = 0.0
var target_zoom: float = 1.0

func _ready():
	# 1. Принудительно вычисляем позицию ПЕРЕД отображением кадра
	var viewport_height = get_viewport_rect().size.y
	# Вычисляем, где должен быть центр камеры, чтобы земля была внизу
	var initial_offset_y = (viewport_height / 2.0 - 150.0) / target_zoom
	global_position.y = ground_y - initial_offset_y
	
	target_position_x = global_position.x
	# Даем камере понять, что это наша базовая позиция
	anchor_mode = Camera2D.ANCHOR_MODE_DRAG_CENTER

func _process(delta):
	_handle_movement(delta)
	_apply_transform(delta)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			target_zoom = clamp(target_zoom + zoom_speed, min_zoom, max_zoom)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			target_zoom = clamp(target_zoom - zoom_speed, min_zoom, max_zoom)

func _handle_movement(delta):
	var move_dir = Input.get_axis("ui_left", "ui_right")
	if move_dir == 0: # Дополнительно проверяем A/D если ui_left не настроен
		if Input.is_key_pressed(KEY_A): move_dir -= 1
		if Input.is_key_pressed(KEY_D): move_dir += 1
	
	target_position_x += move_dir * (speed / target_zoom) * delta
	target_position_x = clamp(target_position_x, limit_min_x, limit_max_x)

func _apply_transform(delta):
	# Плавный зум
	zoom = zoom.lerp(Vector2(target_zoom, target_zoom), zoom_smoothing * delta)
	
	# МАТЕМАТИКА RATROPOLIS
	var viewport_height = get_viewport_rect().size.y
	
	# Вычисляем смещение от центра до линии земли с учетом текущего зума
	# Чем больше зум, тем меньше физическое расстояние в пикселях от центра до края
	var offset_y = (viewport_height / 2.0 - 150.0) / zoom.x
	
	global_position.x = target_position_x
	global_position.y = ground_y - offset_y
	
	# ОГРАНИЧИТЕЛЬ (Чтобы не было серой полосы сверху)
	# Если верхний край камеры (global_position.y - пол-экрана) выше, чем 0
	var half_screen_in_world = (viewport_height / 2.0) / zoom.x
	if global_position.y - half_screen_in_world < 0:
		global_position.y = half_screen_in_world
# Это вызывает Main.gd
func setup_limits(min_x: float, max_x: float, _center_y: float):
	limit_min_x = min_x
	limit_max_x = max_x
