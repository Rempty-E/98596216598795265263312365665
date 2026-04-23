extends Node2D

# Базовые свойства, которые будут у всех зданий
@export var building_name: String = "Здание"
@export var build_cost: int = 0 # Стоимость постройки (если вернем экономику)
@export var production_rate: float = 0.0 # Скорость производства ресурсов
@export var resource_type: String = "" # Какой ресурс производит ("gold", "food", etc.)

var is_active = true

func _ready():
	print("Построено: ", building_name)
	# Запускаем цикл производства, если оно есть
	if production_rate > 0:
		start_production()

func start_production():
	# Простой таймер для производства
	while is_active:
		await get_tree().create_timer(production_rate).timeout
		produce_resource()

func produce_resource():
	if not is_active:
		return
	
	print("Здание '", building_name, "' произвело ресурс: ", resource_type)
	
	# Здесь мы должны сообщить главному менеджеру, что ресурс получен
	# Для этого нам понадобится ссылка на Main или сигнал
	if has_node("/root/Main"):
		get_node("/root/Main").add_resource(resource_type, 1)

func deactivate():
	is_active = false
	print("Здание остановлено")
