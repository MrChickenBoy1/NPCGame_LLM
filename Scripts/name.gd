extends LineEdit

var npc_name = ""

func _on_text_changed(new_text: String) -> void:
	npc_name = new_text
