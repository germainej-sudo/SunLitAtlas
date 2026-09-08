extends Node
var failures: Array = []
var checks: int = 0
var game: Node

func check(condition: bool, message: String) -> void:
	checks+=1
	if not condition:
		failures.append(message);printerr("FAIL: "+message)

func _ready() -> void:
	run.call_deferred()

func click_text(node: Node, prefix: String) -> bool:
	if node is Button and node.text.begins_with(prefix): node.pressed.emit();return true
	for child in node.get_children():
		if click_text(child,prefix): return true
	return false

func run() -> void:
	get_tree().create_timer(45).timeout.connect(func() -> void: printerr("FAIL: test timeout");get_tree().quit(1))
	State.save_enabled=false;State.new_journey(3);State.settings.gentle=true
	game=load("res://scenes/main.tscn").instantiate();add_child(game)
	await get_tree().process_frame
	State.save_prefix="title_remap_test_"+str(Time.get_ticks_usec())+"_"
	State.save_enabled=true
	game.journey_active=false;game.remap_action="compass"
	var remap:=InputEventKey.new();remap.physical_keycode=KEY_F9;remap.pressed=true
	game._unhandled_input(remap)
	check(not FileAccess.file_exists(State.path_for(3)),"Title-screen control changes do not overwrite a journey")
	if FileAccess.file_exists(State.path_for(3)):DirAccess.remove_absolute(State.path_for(3))
	State.bindings.compass=KEY_C;State.configure_input();State.save_enabled=false
	game.journey_active=true;game.mode="menu";game.close_overlay()
	check(game.player.enabled,"Exploration enabled after leaving title")
	check(game.camera.get_parent()==game.player,"Camera follows Liora")
	check(game.camera.limit_right==2400 and game.camera.limit_bottom==1080,"Brightwater camera uses the expanded world limits")
	check(game.player.movement_bounds.end==Vector2(2376,1054),"Player can traverse the full expanded Brightwater area")
	check(not State.solve("synthesis",[1,1,1]),"Final gate rejects unearned evidence")
	check(not State.solve("opening",[1]),"Opening rejects missing evidence")
	game.show_journal()
	var before: Vector2=game.player.position
	Input.action_press("up")
	for _i in range(4):await get_tree().physics_frame
	Input.action_release("up")
	check(game.player.position==before,"Journal suspends player movement")
	game.close_overlay()
	# Reachable playthrough: enter only unlocked doors; operate only eligible objects.
	var reachable: Array=["town"]
	var processed: Dictionary={}
	for iteration in range(30):
		var previous:=State.flags.size()
		for room_id in reachable.duplicate():
			game.load_room(room_id,Vector2(450,350),false)
			await get_tree().process_frame
			for o in State.book.rooms[room_id].objects:
				if processed.has(o.id) or o.kind=="rest" or not State.meets(o.get("need",[])):continue
				game.interact(o)
				if o.kind=="puzzle":
					var p: Dictionary=State.book.puzzles[o.id]
					var wrong: Array=p.answer.duplicate();wrong[0]=(int(wrong[0])+1)%p.choices[0].size()
					check(not State.solve(o.id,wrong),"Wrong configuration rejected: "+o.id)
					game.dial_values=p.answer.duplicate();game.test_puzzle()
					check(State.has(o.id),"Puzzle completes: "+o.id)
				processed[o.id]=true
				game.journey_active=true;game.mode="menu";game.close_overlay()
				if game.mode=="worksheet":
					check(click_text(game.content,"I have finished"),"Paper acknowledgement button present")
				await get_tree().process_frame
			for e in State.book.rooms[room_id].exits:
				if State.meets(e.need) and not e.to in reachable:reachable.append(e.to)
		if previous==State.flags.size() and reachable.size()==State.book.rooms.size():break
	check(State.has("ending"),"Complete central story reaches ending")
	check(reachable.size()==20,"All twenty sectors reachable")
	for i in range(1,7):check(State.has("paper"+str(i)),"Paper milestone %d acknowledged"%i)
	for id in State.book.evidence:check(State.has(id),"Journal source acquired: "+id)
	# Every door uses the specified matching return position.
	for room_id in State.book.rooms:
		for e in State.book.rooms[room_id].exits:
			game.load_room(room_id,Vector2(e.x,e.y+20),false)
			var door: Dictionary=e.duplicate();door.kind="exit";door.name="Test door"
			game.interact(door)
			check(State.room_id==e.to,"Paired transition: "+room_id+" to "+e.to)
			check(game.player.position.distance_to(Vector2(e.spawn[0],e.spawn[1]))<1,"Exact door placement: "+room_id+" to "+e.to)
			await get_tree().process_frame
	# Recovery does not erase knowledge.
	game.journey_active=true;game.mode="menu";game.close_overlay();game.load_room("forest",Vector2(450,350),false)
	State.settings.gentle=false;State.vitality=1;game.t=3.0
	var h: Dictionary=game.hazards[0]
	game.player.position=game.hazard_pos(h);game.player.hurt_time=0;game.update_hazards(.01)
	check(State.vitality==5,"Zero vitality recovers at rest point")
	check(State.has("ending"),"Recovery preserves discoveries")
	# AI offline completion is synchronous and has no state authority.
	var replies: Array=[]
	game.ai.reply.connect(func(text: String) -> void: replies.append(text))
	game.ai.key="";game.ai.ask("Mira","What can the atlas show?",[])
	check(replies.size()==1 and replies[0].begins_with("Offline"),"Offline AI produces authored fallback")
	# Isolated real save roundtrip, version rejection, truncated-file recovery.
	State.save_prefix="integration_test_"+str(Time.get_ticks_usec())+"_"
	State.save_enabled=true;State.room_id="forest";State.player_pos=Vector2(450,350)
	check(State.save_game(),"Atomic initial save")
	State.flags["test_snapshot"]=true
	check(State.save_game(),"Atomic replacement save")
	var path: String=State.path_for(State.profile)
	var data: Variant=JSON.parse_string(FileAccess.get_file_as_string(path))
	check(State.valid_save(data),"Real save validates")
	data.version=900;check(not State.valid_save(data),"Future schema rejected")
	data.version=1;data.position=["bad",12];check(not State.valid_save(data),"Malformed position rejected")
	State.flags={};check(State.load_game(3) and State.has("test_snapshot"),"Full save roundtrip restores flags")
	var corrupt:=FileAccess.open(path,FileAccess.WRITE);corrupt.store_string("{truncated");corrupt.close()
	State.flags={};check(State.load_game(3) and State.has("ending") and not State.has("test_snapshot"),"Corrupt save recovers prior snapshot")
	check(State.save_game(),"Save after recovery repairs the primary")
	for suffix in ["",".bak",".tmp"]:
		if FileAccess.file_exists(path+suffix):DirAccess.remove_absolute(path+suffix)
	State.save_enabled=false
	print("INTEGRATION: %d checks; %d failures"%[checks,failures.size()])
	game.queue_free();await get_tree().process_frame;await get_tree().process_frame
	get_tree().quit(0 if failures.is_empty() else 1)
