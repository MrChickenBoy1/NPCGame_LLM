extends HSlider


var lazy: float = 0.0


func _on_value_changed(value: float) -> void:
	lazy = value
