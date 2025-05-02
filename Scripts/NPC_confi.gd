extends Control

@onready var name_ins: LineEdit = $name
@onready var humour_ins: HSlider = $Humour
@onready var lazy_ins: HSlider = $Lazy
@onready var emotional_ins: HSlider = $Emotional
@onready var eccentric_ins: HSlider = $Eccentric
@onready var active_skills_ins: LineEdit = $active_skills
@onready var passive_skills_ins: LineEdit = $passive_skills

func save_data(name, humour, lazy, emotional, eccentric, active_skills, passive_skills):
	var personality = [{"humour" : humour, "lazy" : lazy, "emotional" : emotional, "eccentric" : eccentric}]
	var npc_data := {
		"name" : name,
		"personality" : personality,
 		"active_skills" : active_skills,
		"passive_skills" : passive_skills,
		"diary_entry" : []
	}
	
	var json_text := JSON.stringify(npc_data, "\t")
	
	var file = FileAccess.open("res://Data/npc_data.json", FileAccess.WRITE)
	if file:
		file.store_string(json_text)
		file.close()
		
	get_tree().change_scene_to_file("res://Scenes/main.tscn")
	
	

func _on_button_pressed() -> void:
	var name = name_ins.name
	var humour = humour_ins.humour
	var lazy = lazy_ins.lazy
	var emotional = emotional_ins.emotional
	var eccentric = eccentric_ins.eccentric
	var active_skills = active_skills_ins.active_skills
	var passive_skills = passive_skills_ins.passive_skills
	
	save_data(name, humour, lazy, emotional, eccentric, active_skills, passive_skills)
	
	
