extends Control

@onready var http_request: HTTPRequest = $HTTPRequest
@onready var waiting: Control = $Waiting
var NPC_SCENE = preload("res://Scenes/npc_scene.tscn")
var json_data = FileAccess.open("res://Data/npc_data.json", FileAccess.READ)
var json_str
var result
var prompt 

func load_secrets() -> Dictionary:
	var file := FileAccess.open("res://secrets/screts.json", FileAccess.READ)
	if file:
		var text := file.get_as_text()
		return JSON.parse_string(text)
	return {}


func NPC_created():
	var NPC_scene = NPC_SCENE.instantiate()
	add_child(NPC_scene)
	NPC_scene.visible = false
	
	
	
func send_to_openrouter(prompt: String) -> void:
	var url = "https://openrouter.ai/api/v1/chat/completions"
	var api_key = load_secrets().get("api_key")
	var headers = [
		"Content-Type: application/json",
		"Authorization: Bearer " + api_key
	]

	var body = {
		"model": "mistralai/mistral-7b-instruct:free",
		"messages": [
			{ "role": "system", "content": "You are an assistant that ONLY returns pure valid JSON lists without any extra text." },
			{ "role": "user", "content": prompt }
		]
	}
	
	var json_string = JSON.stringify(body)
	var err = http_request.request(url, headers, HTTPClient.METHOD_POST, json_string)
	
	if err != OK:
		print("Request error: ", err)



func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code == 200:
		var json_string = body.get_string_from_utf8()
		var data = JSON.parse_string(json_string)

		if data:
			var content = data
			print(content["choices"][0]["message"]["content"])
			NPC_created()
		else:
			print("❌ Failed to parse JSON.")
	else:
		print("❌ HTTP error: ", response_code)
	
		
		
func _ready() -> void:
	if json_data:
		json_str = json_data.get_as_text()
		result = JSON.parse_string(json_str)
	prompt = """
Create a 24-hour schedule (0 to 1440 minutes) for an NPC with the following attributes:
- Personality traits: %s
- Active skills: %s
- Passive skills: %s

Rules:
- Output ONLY a single flat JSON list of dictionaries (NO text or explanation).
- Each task must have these exact keys:
  - "start_minute" (integer): time task starts, 0 ≤ value < 1440
  - "duration" (integer): duration in minutes (sum of all durations must be 1440)
  - "description" (string): short, natural description of the activity
  - "type" (string): one of ["productive", "leisure", "social"]
  - "activity_type" (string): either "active" or "passive"

Guidelines:
- The day should be LESS than or equal to 1440 minutes. All tasks should happen before 1400.
- Schedule must total **exactly 1440 minutes** 
- The day should begin at **(360 minutes)** or after but before (600 minutes).
- Sleep should happen at **the end of the schedule**, lasting **at least 6 hours** and **ending before midnight (1440 minutes)**.
- Sleep duration at night should be such that it ends at 1740 or later.
- Activities should reflect the NPC's personality and skills.
- Include a **balanced mix** of productive, leisure, and social activities.
- Tasks should vary in duration (e.g., 30, 45, 60, 90 minutes).
- **Ensure a logical flow** (e.g., work → break → social time → sleep).
"""% [str(result["personality"]), str(result["active_skills"]), str(result["passive_skills"])]


	send_to_openrouter(prompt)
