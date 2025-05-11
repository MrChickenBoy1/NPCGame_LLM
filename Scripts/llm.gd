extends Control

@onready var http_request: HTTPRequest = $HTTPRequest
@onready var waiting: Control = $Waiting
@onready var timer: Timer = $Timer

var NPC_SCENE = preload("res://Scenes/npc_scene.tscn")
var json_data = FileAccess.open("res://Data/npc_data.json", FileAccess.READ)
var json_str
var result
var prompt
var time_elapsed 
var start_npc
var schedule_json
var time_schedule
var NPC_scene
var day = 0
var type_prompt
var normal_string

func load_secrets() -> Dictionary:
	var file := FileAccess.open("res://secrets/screts.json", FileAccess.READ)
	if file:
		var text := file.get_as_text()
		return JSON.parse_string(text)
	return {}


func load_schedule(schedule_str):
	var schedule_json = JSON.parse_string(schedule_str)
	return schedule_json
	

func NPC_created(schedule_json):
	time_schedule = []
	
	if waiting.is_visible_in_tree():
		waiting.queue_free()
	if NPC_scene == null:
		NPC_scene = NPC_SCENE.instantiate()
		add_child(NPC_scene)
		NPC_scene.get_child(0).text = "Currently: "+schedule_json[0]["activity"]
	
	var iter = 0
	for i in schedule_json:
		print (i)
		time_schedule.append([])
		time_schedule[iter].append(i["start"])
		time_schedule[iter].append(i["start"] +i["duration"] )
		iter += 1
	print(time_schedule)
	
	return time_schedule
	
	
	
func send_to_openrouter(prompt: String, system: String) -> void:
	var url = "https://openrouter.ai/api/v1/chat/completions"
	var api_key = load_secrets().get("api_key")
	var headers = [
		"Content-Type: application/json",
		"Authorization: Bearer " + api_key
	]

	var body = {
		"model": "meta-llama/llama-3.2-3b-instruct:free",
		"messages": [
			{ "role": "system", "content": system},
			{ "role": "user", "content": prompt }
		]
	}
	
	var json_string = JSON.stringify(body)
	var err = http_request.request(url, headers, HTTPClient.METHOD_POST, json_string)
	
	if err != OK:
		print("Request error: ", err)


func clean_json_string(raw_string: String) -> String:
	var cleaned = raw_string.strip_edges()

	# Try to isolate the JSON using first and last square brackets
	var start_index = cleaned.find("[")
	var end_index = cleaned.rfind("]")

	if start_index == -1 or end_index == -1:
		return ""  # JSON not found

	# Extract only the JSON array portion
	cleaned = cleaned.substr(start_index, end_index - start_index + 1)
	return cleaned


func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code == 200:
		print(type_prompt)
		if type_prompt == "json":
			var json_string = body.get_string_from_utf8()
			var parsed = JSON.parse_string(json_string)
		
			if parsed:
				print(parsed)
				var raw_output = parsed["choices"][0]["message"]["content"]
				var cleaned_json = clean_json_string(raw_output)
				var final_data = JSON.parse_string(cleaned_json)

				if final_data:
					schedule_json = load_schedule(cleaned_json)
					timer.start(86400)
					await get_tree().process_frame
					await get_tree().create_timer(0.1).timeout
					start_npc = true

				else:
					print("❌ JSON parse failed after cleaning.")
			else:
				print("❌ Unexpected JSON format from OpenRouter.")
		elif type_prompt == "normal":
			normal_string = body.get_string_from_utf8()
			normal_string = JSON.parse_string(normal_string)
			print(normal_string["choices"][0]["message"]["content"])
			
			
			
	else:
		print("❌ HTTP error: ", response_code)

	
		
		
func _ready() -> void:
	if json_data:
		json_str = json_data.get_as_text()
		result = JSON.parse_string(json_str)
	prompt = """You are simulating a **compressed 24-hour day** in just **60 real-time minutes** for a virtual NPC.

🧠 NPC Details:
- Name: %s
- Personality: %s
- Hobbies:
  - passive: %s
  - active: %s

🕒 Simulation Concept:
- This is a **miniature 1-hour version of a full day**.
- Each minute represents ~24 minutes in a normal day.
- The NPC should go through a believable "day cycle": waking up, working, eating, socializing, relaxing, and sleeping.
- Think of this as simulating an entire day in fast-forward.

🗓 Output Format (JSON List Only):
Return a list of **non-overlapping tasks** representing this fast-forwarded day. Each task is a dictionary with:
- `"start"`: start time in minutes (0–59)
- `"duration"`: duration in minutes (1–60)
- `"activity"`: short **present continuous** verb phrase (e.g., "reading book", "eating snack", "talking with friend")
- `"type"`: "active" or "passive"
- `"category"`: "work", "leisure", "social", or "personal"

🧠 Personality Affects:
- **Lazy** → fewer intense tasks, more passive moments
- **Eccentric** → unexpected or creatively placed tasks
- **Emotional** → deeper reflection or journaling
- Use hobbies to inspire specific activities

⚠ Rules:
- Simulate a **whole day compressed into 1 hour**
- Total duration of tasks must fit between **0–60 minutes**
- Tasks must **not overlap**
- Must include **work**, **leisure**, **social**, and **personal** activities
- Think in terms of a **fast-forwarded full day**, not just one hour

📝 Language Requirement:
- The "activity" field **must** use a present continuous verb form (e.g., “listening to music”, “writing notes”, “watching video”).

**VERY IMPORTANT**  
- Only return valid **raw JSON** — no markdown, no explanation, no surrounding text.

📤 Output Example:
[
  { "start": 0, "duration": 5, "activity": "waking up", "type": "passive", "category": "personal" },
  { "start": 5, "duration": 10, "activity": "reading book", "type": "passive", "category": "leisure" },
  { "start": 15, "duration": 10, "activity": "coding project", "type": "active", "category": "work" },
  { "start": 25, "duration": 5, "activity": "chatting online", "type": "passive", "category": "social" },
  { "start": 30, "duration": 5, "activity": "eating lunch", "type": "passive", "category": "personal" },
  { "start": 35, "duration": 10, "activity": "going for walk", "type": "active", "category": "personal" },
  { "start": 45, "duration": 5, "activity": "browsing internet", "type": "passive", "category": "leisure" },
  { "start": 50, "duration": 5, "activity": "writing journal", "type": "passive", "category": "personal" },
  { "start": 55, "duration": 5, "activity": "falling asleep", "type": "passive", "category": "personal" }
]"""% [str(result["name"]), str(result["personality"]), str(result["passive_skills"]), str(result["active_skills"])]

	type_prompt = "json"
	send_to_openrouter(prompt, "You are an assistant that ONLY returns pure valid JSON lists without any extra text.")

var task_end = 0
var task_current

func _process(delta: float) -> void:
	time_elapsed = 86400 - timer.time_left
	if (start_npc == true):
		NPC_created(schedule_json)
		start_npc = false
		
	if time_elapsed < 86400 and time_schedule != null:
		var iter = 0
		if time_elapsed > task_end:
			for i in time_schedule:
				if time_elapsed > i[0] and time_elapsed < i[1]:
					task_current = iter
					task_end = i[1]
					print (task_current)
				iter += 1
				
			NPC_scene.get_child(1).text = "From " + str(int(time_schedule[task_current][0])) + " seconds to " + str(int(time_schedule[task_current][1])) + " seconds."
			NPC_scene.get_child(0).text = "Currently: "+schedule_json[task_current]["activity"]
			
			var prompt = """You are an NPC simulation system.
Given the personality, skills (active and passive) and the current activity of the NPC, generate a single realistic one-line note about how the NPC experienced or reacted to that activity.
Do not include any explanations, formatting, or additional text. Just return the one-line note.

Personality: %s
Activity: %s
Active skills: %s
Passive skills: %s

Respond with just one natural sentence describing the activity from the NPC’s point of view."""% [str(result["personality"]), str(schedule_json[task_current]["activity"]), str(result["active_skills"]), str(result["passive_skills"])]
			type_prompt = "normal"
			send_to_openrouter(prompt, "You are an internal narrative generator for an NPC in a life simulation.
										Your role is to create short, realistic diary-style thoughts or reflections based on the NPC’s personality and current activity.
										Keep each note natural, personal, and written in the NPC’s internal voice.
										The note should be one sentence only, describing how the NPC felt or experienced the moment.
										Be sensitive to the personality (e.g., anxious people may overthink, outgoing people may enjoy social interactions). Keep the note very casual, and human, keep it simple.
										Avoid repeating sentence structures and do not use any quotes, bullet points, or formatting.")
			await get_tree().create_timer(10.0).timeout
			
			$sql_db.add_data_activtity()


func _on_timer_timeout() -> void:
	start_npc = false
	var new_day_prompt = """You are simulating a **compressed 24-hour day** in just **60 real-time minutes** for a virtual NPC.

🧠 NPC Details:
- Name: %s
- Personality: %s
- Hobbies:
  - passive: %s
  - active: %s

📅 Previous Day Schedule (in JSON):
%s

🧠 Your Task:
Generate a new schedule for **today**, based on the **previous day's**. The NPC should follow a roughly similar pattern, but:
- Change **at least 30%%** of the activities subtly
- Adjust start times and durations slightly, to reflect human-like variability
- Add new or replace old activities that feel organic to the NPC’s life
- Base changes on personality: lazy = lower effort, eccentric = more spontaneous or weird shifts, emotional = more introspective or personal time

🕒 Simulation Concept:
- This is a **miniature 1-hour version of a full day**
- Each minute = ~24 minutes of real life
- The NPC goes through waking, working, eating, socializing, relaxing, and sleeping — all in 60 minutes

🗓 Output Format (JSON List Only):
Return a list of **non-overlapping tasks** representing this fast-forwarded day. Each task is a dictionary with:
- `"start"`: start time in minutes (0–59)
- `"duration"`: duration in minutes (1–60)
- `"activity"`: short **present continuous** verb phrase (e.g., "reading book", "eating snack", "talking with friend")
- `"type"`: "active" or "passive"
- `"category"`: "work", "leisure", "social", or "personal"

⚠ Rules:
- Total time must fit inside 60 minutes
- No overlapping tasks
- Must include **at least one** of each category: **work**, **leisure**, **social**, and **personal**
- “activity” field must always use **present continuous verb form** (e.g., “watching video” not “watch video”)

📝 Output Requirement:
- Return **ONLY valid JSON**
- No markdown, no extra notes, no explanation — only raw JSON list of activities

📤 Output Example:
[
  { "start": 0, "duration": 5, "activity": "waking up", "type": "passive", "category": "personal" },
  { "start": 5, "duration": 10, "activity": "reading book", "type": "passive", "category": "leisure" },
  { "start": 15, "duration": 10, "activity": "coding project", "type": "active", "category": "work" },
  { "start": 25, "duration": 5, "activity": "chatting online", "type": "passive", "category": "social" },
  { "start": 30, "duration": 5, "activity": "eating lunch", "type": "passive", "category": "personal" },
  { "start": 35, "duration": 10, "activity": "going for walk", "type": "active", "category": "personal" },
  { "start": 45, "duration": 5, "activity": "browsing internet", "type": "passive", "category": "leisure" },
  { "start": 50, "duration": 5, "activity": "writing journal", "type": "passive", "category": "personal" },
  { "start": 55, "duration": 5, "activity": "falling asleep", "type": "passive", "category": "personal" }
]
"""% [str(result["name"]), str(schedule_json[task_current]["personality"]), str(result["passive_skills"]), str(result["active_skills"]), str(schedule_json)]
	day += 1
	type_prompt = "json"
	send_to_openrouter(new_day_prompt, "You are an assistant that ONLY returns pure valid JSON lists without any extra text.")
