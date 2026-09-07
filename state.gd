extends Node
## Sole owner of durable progress. UI never awards progress directly.
signal changed
signal saved(ok: bool)
var book: Dictionary
var layouts: Dictionary
var flags: Dictionary = {}
var visited: Array = []
var room_id: String = "town"
var player_pos := Vector2(450, 350)
var vitality: int = 5
var profile: int = 1
var seconds: float = 0.0
var settings: Dictionary = {"gentle": false, "music": true, "motion": true}
var save_enabled: bool = true
var save_prefix: String = "journey_"
var bindings: Dictionary = {"left": KEY_A, "right": KEY_D, "up": KEY_W, "down": KEY_S, "interact": KEY_E, "staff": KEY_SPACE, "dodge": KEY_Q, "journal": KEY_J, "map": KEY_M, "compass": KEY_C}

func _ready() -> void:
	book = JSON.parse_string(FileAccess.get_file_as_string("res://data/world.json"))
	layouts = JSON.parse_string(FileAccess.get_file_as_string("res://data/layout.json"))
	configure_input()

func configure_input() -> void:
	for action in bindings:
		if not InputMap.has_action(action): InputMap.add_action(action)
		InputMap.action_erase_events(action)
		var event := InputEventKey.new()
		event.physical_keycode = int(bindings[action])
		InputMap.action_add_event(action, event)
	for pair in [["left",KEY_LEFT],["right",KEY_RIGHT],["up",KEY_UP],["down",KEY_DOWN]]:
		var event := InputEventKey.new()
		event.physical_keycode = pair[1]
		InputMap.action_add_event(pair[0], event)
	if not InputMap.has_action("pause"): InputMap.add_action("pause")
	InputMap.action_erase_events("pause")
	var pause_key:=InputEventKey.new();pause_key.physical_keycode=KEY_ESCAPE;InputMap.action_add_event("pause",pause_key)
	var pause_pad:=InputEventJoypadButton.new();pause_pad.button_index=JOY_BUTTON_START;InputMap.action_add_event("pause",pause_pad)
	for pair in [["interact",JOY_BUTTON_A],["staff",JOY_BUTTON_X],["dodge",JOY_BUTTON_B],["journal",JOY_BUTTON_Y]]:
		var event := InputEventJoypadButton.new()
		event.button_index = pair[1]
		InputMap.action_add_event(pair[0],event)

func new_journey(slot: int) -> void:
	profile = clampi(slot,1,3)
	flags = {}
	visited = ["town"]
	room_id = "town"
	player_pos = Vector2(450,350)
	vitality = 5
	seconds = 0.0
	changed.emit()

func has(id: String) -> bool:
	return bool(flags.get(id,false))

func meets(needs: Array) -> bool:
	for id in needs:
		if not has(str(id)): return false
	return true

func grant(id: String) -> void:
	if id.is_empty() or has(id): return
	flags[id] = true
	changed.emit()
	save_game()

func solve(id: String, values: Array) -> bool:
	if not book.puzzles.has(id): return false
	var p: Dictionary = book.puzzles[id]
	if not meets(p.need) or values != p.answer: return false
	flags[id] = true
	for award in p.award: flags[award] = true
	for reward in p.reward: flags[reward] = true
	changed.emit()
	save_game()
	return true

func pending_paper() -> int:
	for p in book.puzzles.values():
		if int(p.paper) > 0 and has(_puzzle_id(p)) and not has("paper"+str(int(p.paper))): return int(p.paper)
	return 0

func _puzzle_id(p: Dictionary) -> String:
	for id in book.puzzles:
		if book.puzzles[id] == p: return id
	return ""

func objective() -> Array:
	if not has("atlas"): return ["Meet Mira and read the atlas", "cartography"]
	if not has("opening"): return ["Compare banner & foundation; align the arrow", "town"]
	if not has("paper1"): return ["Record your first prediction on paper", "town"]
	if not has("staff") or not has("song"): return ["Visit Orin in the ranger lodge", "lodge"]
	if not has("forest"): return ["Follow the old marks through Sunleaf", "forest"]
	if not has("line"): return ["Meet Tavi at Reedbank", "river"]
	if not has("sluice"): return ["Balance the sluice for ferry and reeds", "sluice"]
	if not has("river"): return ["Reconstruct why the road changed", "river"]
	if not has("lens"): return ["Meet Sela on the Mosaic Terrace", "ruins"]
	if not has("tracing"): return ["Inspect the atlas tracing with the lens", "ruins"]
	if not has("copies") or not has("guardian"): return ["Trace the copied route; reset the guardian", "copies"]
	if not has("lantern"): return ["Find Inez at Beacon Point", "coast"]
	if not has("beacon"): return ["Restore the lighthouse signal", "lighthouse"]
	for island in [["bell_seal","bell"],["gull_seal","gull"],["lantern_seal","lantern"]]:
		if not has(island[0]): return ["Recover the Coastkeeper seal fragments", island[1]]
	if not meets(["handbill","missing","accounts"]): return ["Find the missing record in the storehouse", "store"]
	if not has("coast"): return ["Assemble Inez’s public shore case", "coast"]
	if not has("civic"): return ["Return to the civic archive in Brightwater", "hall"]
	for task in [["ferry","river","Test the restored public ferry"],["habitat_route","forest","Protect the grove’s marked trail"],["markers","ruins","Authenticate the route markers"],["access_route","coast","Reopen a safe public shore walkway"],["route","town","Build the living route with Mira"]]:
		if not has(task[0]): return [task[2],task[1]]
	if not has("rescue"): return ["Take the north road; help the council ascend", "mountain"]
	if not has("synthesis"): return ["Defend the living route at the summit", "summit"]
	if not has("ending"): return ["Light the living line", "summit"]
	return ["The valley celebrates · explore the remaining islands", "summit"]

func path_for(slot: int) -> String:
	return "user://"+save_prefix+str(slot)+".json"

func save_game() -> bool:
	if not save_enabled: return true
	var data := {"version":1,"flags":flags,"visited":visited,"room":room_id,"position":[player_pos.x,player_pos.y],"vitality":vitality,"seconds":seconds,"settings":settings,"bindings":bindings}
	var path := path_for(profile)
	var f := FileAccess.open(path+".tmp",FileAccess.WRITE)
	if f == null:
		saved.emit(false)
		return false
	f.store_string(JSON.stringify(data)); f.flush(); f.close()
	# Preserve a known-good previous snapshot, then atomically replace.
	if FileAccess.file_exists(path):
		var prior_parser:=JSON.new()
		if prior_parser.parse(FileAccess.get_file_as_string(path))==OK and valid_save(prior_parser.data):
			DirAccess.copy_absolute(path,path+".bak")
	var ok := DirAccess.rename_absolute(path+".tmp",path) == OK
	saved.emit(ok)
	return ok

func valid_save(data: Variant) -> bool:
	if not data is Dictionary: return false
	if data.get("version") != 1 or not book.rooms.has(data.get("room","")): return false
	if not data.get("flags") is Dictionary or not data.get("visited") is Array: return false
	for value in data.flags.values():
		if not value is bool: return false
	var pos: Variant = data.get("position")
	if not pos is Array or pos.size()!=2: return false
	for value in pos:
		if not (value is float or value is int) or not is_finite(float(value)): return false
	if not data.get("vitality") is float and not data.get("vitality") is int: return false
	if not data.get("seconds",0) is float and not data.get("seconds",0) is int: return false
	return true

func load_game(slot: int) -> bool:
	for suffix in ["", ".bak"]:
		var path: String = path_for(slot)+suffix
		if not FileAccess.file_exists(path): continue
		var parser := JSON.new()
		if parser.parse(FileAccess.get_file_as_string(path)) != OK: continue
		var data: Variant = parser.data
		if not valid_save(data): continue
		profile = slot
		flags = data.flags
		visited = data.visited.filter(func(v: Variant) -> bool: return book.rooms.has(v))
		room_id = data.room
		player_pos = Vector2(clampf(data.position[0],30,930),clampf(data.position[1],65,505))
		vitality = clampi(int(data.vitality),1,5)
		seconds = maxf(0,float(data.get("seconds",0)))
		if data.get("settings") is Dictionary:
			for key in settings:
				if data.settings.get(key) is bool: settings[key] = data.settings[key]
		if data.get("bindings") is Dictionary:
			for key in bindings:
				var code: Variant = data.bindings.get(key)
				if (code is float or code is int) and int(code)>0: bindings[key] = int(code)
		configure_input()
		changed.emit()
		return true
	return false
