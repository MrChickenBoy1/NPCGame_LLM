extends Node

var database : SQLite
var path_db = "res://Data/npc_data.db"

func _ready():
	if get_tree().current_scene.name == "npc_creation":
		database = SQLite.new()
		database.path = "res://Data/npc_data.db"
		database.open_db()




func _on_button_pressed() -> void:
	print(get_parent().name)
	var table_conf = {
				"id" : {"data_type":"int", "primary_key":true, "not_null":true, "auto_increment": true},
				"name" : {"data_type" : "text"},
				"humour" : {"data_type" : "bool"},
				"lazy" : {"data_type" : "bool"},
				"emotional" : {"data_type" : "bool"},
				"eccentric" : {"data_type" : "bool"},
				
			}
			
	database.create_table("npc_personality", table_conf)
			
	var data = {
		"name" : get_parent().name_ins.npc_name,
		"humour" : get_parent().humour_ins.humour,
		"lazy" : get_parent().lazy_ins.lazy,
		"emotional" : get_parent().emotional_ins.emotional,
		"eccentric" : get_parent().eccentric_ins.eccentric,
		
	}
	
	database.insert_row("npc_personality", data)
