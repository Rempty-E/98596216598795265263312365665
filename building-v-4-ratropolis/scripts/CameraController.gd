extends Camera2D

# --- НАСТРОЙКИ ---
@export var speed: float = 1000.0         # Скорость движения (A/D)
@export var drag_sensitivity: float = 1.0 # Чувствительность мыши

# Зум
@export var zoom_speed: float = 0.1
@export var min_zoom: float = 1.0        # Держи 1.0+, чтобы не было полос сверху
@export var max_zoom: float = 2.5
@export var zoom_smoothing: float = 10.0

# --- ПРИВЯЗКА К ЗЕМЛЕ ---
@export var ground_y: float = 760.0      # Y координата твоей сетки

# --- ВНУТРЕННИЕ ПЕРЕМЕННЫЕ ---
var limit_min_x: float = -17000.0
var limit_max_x: float = 17000.0
var base_y: float = 540.0

var target_position: Vector2 = Vector2.ZERO
var target_zoom: float = 1.0

var is_dragging: bool = false
var last_mouse_pos: Vector2 = Vector2.ZERO

func _ready():
	base_y = global_position.y
	target_position = global_position
	target_zoom = zoom.x

func _process(delta):
	_handle_keyboard(delta) # ВОЗВРАЩАЕМ КЛАВИАТУРУ
	_apply_transform(delta)

func _input(event):
	_handle_mouse_drag(event) # ВОЗВРАЩАЕМ МЫШКУ
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			target_zoom = clamp(target_zoom + zoom_speed, min_zoom, max_zoom)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			target_zoom = clamp(target_zoom - zoom_speed, min_zoom, max_zoom)

# --- ЛОГИКА ДВИЖЕНИЯ В СТОРОНЫ ---

func _handle_keyboard(delta):
	var move_dir := 0.0
	if Input.is_key_pressed(KEY_A) or Input.is_action_pressed("ui_left"):
		move_dir -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_action_pressed("ui_right"):
		move_dir += 1.0
	
	if move_dir != 0.0:
		# Учитываем зум: чем ближе камера, тем плавнее она едет
		target_position.x += move_dir * (speed / target_zoom) * delta
		target_position.x = clamp(target_position.x, limit_min_x, limit_max_x)

func _handle_mouse_drag(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			is_dragging = event.pressed
			if is_dragging:
				last_mouse_pos = get_viewport().get_mouse_position()
	
	if is_dragging and event is InputEventMouseMotion:
		var current := get_viewport().get_mouse_position()
		# Двигаем только по X
		var diff_x = (last_mouse_pos.x - current.x) / zoom.x
		target_position.x += diff_x * drag_sensitivity
		target_position.x = clamp(target_position.x, limit_min_x, limit_max_x)
		last_mouse_pos = current

# --- ЛОГИКА ТРАНСФОРМАЦИИ (ЗУМ + ПОЗИЦИЯ) ---

func _apply_transform(delta):
	# Плавный зум
	zoom = zoom.lerp(Vector2(target_zoom, target_zoom), zoom_smoothing * delta)
	
	# Вычисляем Y-смещение для фиксации земли
	var zoom_factor = 1.0 - (1.0 / zoom.x)
	var offset_y = (ground_y - base_y) * zoom_factor
	
	# Итоговая позиция: X от игрока, Y от зума
	global_position.x = target_position.x
	global_position.y = base_y + offset_y

func setup_limits(min_x: float, max_x: float, center_y: float):
	limit_min_x = min_x
	limit_max_x = max_x
	base_y = center_y
	target_position.y = center_y
