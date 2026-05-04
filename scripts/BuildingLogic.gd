extends Node
class_name BuildingLogic

var data: BuildingData # Сюда Main.gd передаст данные о здании
var main_node: Node2D  # Ссылка на главный узел для вызова add_resource

func _ready():
	if data and data.production_rate > 0:
		start_production()

func start_production():
	while true:
		await get_tree().create_timer(data.production_rate).timeout
		produce_resource()

func produce_resource():
	if main_node:
		main_node.add_resource(data.resource_type, data.resource_amount)
