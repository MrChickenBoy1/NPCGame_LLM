extends Control

@onready var http_request: HTTPRequest = $HTTPRequest
@onready var waiting: Control = $Waiting
var NPC_SCENE = preload("res://Scenes/npc_scene.tscn")


func load_secrets() -> Dictionary:
	var file := FileAccess.open("res://secrets/screts.json", FileAccess.READ)
	if file:
		var text := file.get_as_text()
		return JSON.parse_string(text)
	return {}






func NPC_created():
	waiting.queue_free()
	var NPC_scene = NPC_SCENE.instantiate()
	add_child(NPC_scene)
	
	
	

func send_to_openrouter(prompt: String) -> void:
	var url = "https://openrouter.ai/api/v1/chat/completions"
	var api_key = load_secrets().get("api_key")
	var headers = [
		"Authorization: Bearer " + api_key
	]
	
	var body = {
		"model": "meta-llama/llama-3.2-3b-instruct:free",  # or another available OpenRouter model
		"prompt" : prompt
	}
	
	var json_string = JSON.stringify(body)
	print("sending: ", json_string)
	var err = http_request.request(url, headers, HTTPClient.METHOD_POST, json_string)
	
	if err != OK:
		print("Request error: ", err)


func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code == 200:
		var json_string = body.get_string_from_utf8()
		var data = JSON.parse_string(json_string)

		if data:
			var content = data
			NPC_created()
		else:
			print("❌ Failed to parse JSON.")
	else:
		print("❌ HTTP error: ", response_code)
	
		
		
func _ready() -> void:


	send_to_openrouter("Tell me a bit about yourself, keep it short")
