extends LineEdit


var active_skills: Array = []



func _on_text_changed(new_text: String) -> void:
	active_skills = new_text.split(",")
	
