extends Resource
class_name BuildingData

@export var name: String = "Новое здание"
@export var texture: Texture2D = null
@export var production_rate: float = 1.0 # Секунды между производством
@export var resource_type: String = "gold"
@export var resource_amount: int = 1
@export var width_in_cells: int = 1 # NEW! Ширина здания в клетках	

# Можно добавить и другие свойства: стоимость, здоровье, и т.д.
