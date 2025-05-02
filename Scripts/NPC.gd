extends Control

var json_data = FileAccess.open("res://Data/npc_data.json", FileAccess.READ)
var json_str
var result
@onready var activity_label: RichTextLabel = $Title



func _ready() -> void:
	print ("NPC boi is here mfs")
	
	if json_data:
		json_str = json_data.get_as_text()
		result = JSON.parse_string(json_str)
		activity_label.text = result["name"] + "'s Activities"
		
