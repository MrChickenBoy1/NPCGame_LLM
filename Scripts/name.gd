extends LineEdit

func _ready() -> void:
	var name = ""


func _on_text_changed(new_text: String) -> void:
	name = new_text
