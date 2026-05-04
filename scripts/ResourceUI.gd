extends CanvasLayer

# Ссылки на метки (Labels). Godot найдет их автоматически по имени, если они есть в сцене
@onready var gold_label = $Background/HBoxContainer/Gold/Gold_label
@onready var food_label = $Background/HBoxContainer/Food/Food_label
@onready var people_label = $Background/HBoxContainer/Population/Population_label

# Функция для обновления значений извне
func update_resources(gold: int, food: int, people: int):
	if gold_label:
		gold_label.text = str(gold)
	if food_label:
		food_label.text = str(food)
	if people_label:
		people_label.text = str(people)
