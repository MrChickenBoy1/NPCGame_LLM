extends LineEdit

var passive_skills: Array = []


func _on_text_changed(new_text: String) -> void:
	passive_skills = new_text.split(",")
	print(passive_skills)
