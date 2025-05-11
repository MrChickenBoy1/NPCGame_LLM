extends Node

var database : SQLite
var path_db = "res://Data/npc_data.db"

func _ready():
	print(get_tree().current_scene.name)
	database = SQLite.new()
	database.path = "res://Data/npc_data.db"
	database.open_db()
	if (get_tree().current_scene.name == "Main"):
		config_activity_db()
		

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
	
	var success = database.insert_row("npc_activity_log", data)
	if success:
		print("Insert successful")
	else:
		print("Insert failed")



func config_activity_db() -> void:
	var activty_conf = {
				"id" : {"data_type":"int", "primary_key":true, "not_null":true, "auto_increment": true},
				"day" : {"data_type" : "int"},
				"start_time" : {"data_type" : "float"},
				"end_time" : {"data_type" : "float"},
				"activity" : {"data_type" : "text"},
				"type" : {"data_type" : "text"},
				"category" : {"data_type" : "text"},
				"note" : {"data_type" : "text"},
				
			}
			
	database.create_table("npc_activity_log", activty_conf)
			
func add_data_activtity():
	
	var data = {
		"day" : get_parent().day,
		"start_time" : int(get_parent().time_schedule[get_parent().task_current][0]),
		"end_time" : int(get_parent().time_schedule[get_parent().task_current][0]+get_parent().time_schedule[get_parent().task_current][1]),
		"activity" : get_parent().schedule_json[get_parent().task_current]["activity"],
		"type" : get_parent().schedule_json[get_parent().task_current]["type"],
		"category" : get_parent().schedule_json[get_parent().task_current]["category"],
		"note" : get_parent().normal_string["choices"][0]["message"]["content"],
		
	}
	
	database.insert_row("npc_activity_log", data)
	print("hello")

	
