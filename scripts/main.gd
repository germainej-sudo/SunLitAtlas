extends Node2D
## World composition and presentation. Durable progression belongs to State.
const PLAYER = preload("res://scripts/player.gd")
const AI = preload("res://scripts/ai_dialogue.gd")
const GOLD = Color("f6d477")
const CREAM = Color("f8edce")
const TEAL = Color("103d43")
var world: Node2D
var player: CharacterBody2D
var camera: Camera2D
var hud: CanvasLayer
var ui: Control
var top: PanelContainer
var objective_label: Label
var region_label: Label
var vitality_label: Label
var prompt: Label
var notice: Label
var overlay: PanelContainer
var content: VBoxContainer
var mode: String = "title"
var journey_active: bool = false
var target: Dictionary = {}
var actors: Array = []
var crowd: Array = []
var markers: Array = []
var hazards: Array = []
var t: float = 0.0
var toast_time: float = 0.0
var ai: Node
var music: AudioStreamPlayer
var music_id: String = ""
var current_puzzle: String = ""
var dial_values: Array = []
var hint_level: int = 0
var hint_label: Label
var remap_action: String = ""
var ai_output: Label
var evidence_pins: Array = []
var transition_time: float = 0.0

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	ai = AI.new(); add_child(ai); ai.reply.connect(_ai_reply)
	music = AudioStreamPlayer.new(); add_child(music)
	music.volume_db = -16
	
	make_ui()
	State.saved.connect(func(ok: bool) -> void: toast("Journey saved" if ok else "Save failed — check your disk space"))
	load_room("town",Vector2(450,350),false)
	show_title()
	if "--smoke" in OS.get_cmdline_user_args():
		State.save_enabled = false
		State.new_journey(3)
		journey_active=true
		load_room("town",Vector2(450,350),false)
		mode="menu"
		close_overlay()
	if "--capture" in OS.get_cmdline_user_args():
		capture.call_deferred()

func capture() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://docs/brightwater-preview.png")
	print("CAPTURE: ",ProjectSettings.globalize_path("res://docs/brightwater-preview.png"))

func style(bg: Color, border: Color = Color("6d9b91")) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg; s.border_color = border
	s.set_border_width_all(1); s.set_corner_radius_all(5)
	s.content_margin_left=10; s.content_margin_right=10; s.content_margin_top=7; s.content_margin_bottom=7
	return s

func label(text: String, size: int = 12, color: Color = CREAM) -> Label:
	var l := Label.new()
	l.text = text; l.add_theme_font_size_override("font_size",size); l.add_theme_color_override("font_color",color)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l

func button(text: String, action: Callable, parent: Node = null) -> Button:
	var b := Button.new(); b.text=text
	b.add_theme_font_size_override("font_size",12)
	b.add_theme_stylebox_override("normal",style(Color("20565a"),Color("568a80")))
	b.add_theme_stylebox_override("hover",style(Color("347570"),GOLD))
	b.add_theme_stylebox_override("focus",style(Color("347570"),GOLD))
	b.add_theme_stylebox_override("pressed",style(Color("426e5c"),GOLD))
	b.add_theme_color_override("font_color",CREAM)
	b.pressed.connect(action)
	(parent if parent!=null else content).add_child(b)
	return b

func make_ui() -> void:
	hud=CanvasLayer.new();add_child(hud)
	ui=Control.new();ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);ui.mouse_filter=Control.MOUSE_FILTER_IGNORE;hud.add_child(ui)
	top=PanelContainer.new();top.position=Vector2(8,7);top.size=Vector2(624,39);top.add_theme_stylebox_override("panel",style(TEAL));ui.add_child(top)
	var row:=HBoxContainer.new();row.add_theme_constant_override("separation",12);top.add_child(row)
	region_label=label("BRIGHTWATER",13,GOLD);region_label.custom_minimum_size.x=139;row.add_child(region_label)
	objective_label=label("Meet Mira at the atlas table",12);objective_label.size_flags_horizontal=Control.SIZE_EXPAND_FILL;row.add_child(objective_label)
	vitality_label=label("● ● ● ● ●",12,GOLD);vitality_label.custom_minimum_size.x=80;row.add_child(vitality_label)
	prompt=label("",12);prompt.position=Vector2(125,327);prompt.size=Vector2(390,26);prompt.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	prompt.add_theme_stylebox_override("normal",style(TEAL));ui.add_child(prompt)
	notice=label("",11,GOLD);notice.position=Vector2(14,49);notice.size=Vector2(610,28);ui.add_child(notice)
	var shortcuts:=HBoxContainer.new();shortcuts.position=Vector2(468,304);ui.add_child(shortcuts)
	button("Journal",show_journal,shortcuts);button("Map",show_map,shortcuts)

func modal(title: String, subtitle: String = "") -> void:
	ai.cancel()
	if is_instance_valid(overlay): overlay.queue_free(); overlay=null
	player.enabled=false
	mode="menu"
	overlay=PanelContainer.new();overlay.position=Vector2(30,55);overlay.size=Vector2(580,296)
	overlay.add_theme_stylebox_override("panel",style(Color("103a40f5"),Color("bca771")));ui.add_child(overlay)
	var column:=VBoxContainer.new();column.add_theme_constant_override("separation",5);overlay.add_child(column)
	var header:=HBoxContainer.new();column.add_child(header)
	var heading:=label(title,21,GOLD);heading.size_flags_horizontal=Control.SIZE_EXPAND_FILL;header.add_child(heading)
	button("×",close_overlay,header)
	if not subtitle.is_empty(): column.add_child(label(subtitle,11,Color("afd3bd")))
	var scroll:=ScrollContainer.new();scroll.size_flags_vertical=Control.SIZE_EXPAND_FILL;scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED;column.add_child(scroll)
	content=VBoxContainer.new();content.size_flags_horizontal=Control.SIZE_EXPAND_FILL;content.add_theme_constant_override("separation",7);scroll.add_child(content)
	focus_first.call_deferred()

func close_overlay() -> void:
	if mode=="title": return
	if not journey_active:
		show_title();return
	ai.cancel()
	if is_instance_valid(overlay): overlay.queue_free();overlay=null
	mode="explore"
	player.enabled=true
	current_puzzle=""
	remap_action=""
	var paper:=State.pending_paper()
	if paper>0: show_worksheet(paper)

func show_title() -> void:
	journey_active=false
	modal("THE SUNLIT ATLAS", "PATHS OF BRIGHTWATER  /  A journey through evidence, memory, and change")
	mode="title"
	content.add_child(label("Two processions claim different routes. Become Liora, Brightwater’s new Wayfinder, and follow a mystery from the twin oaks to the sea.",15))
	content.add_child(label("Compact GDD v2 adaptation · 20 locations · Fully playable offline",11,Color("afd3bd")))
	for slot in range(1,4):
		var row:=HBoxContainer.new();content.add_child(row)
		button("New journey · %d"%slot,func() -> void: confirm_new(slot),row)
		var b:=button("Continue · %d"%slot,func() -> void: continue_journey(slot),row)
		b.disabled=not FileAccess.file_exists(State.path_for(slot)) and not FileAccess.file_exists(State.path_for(slot)+".bak")
	button("Controls & accessibility",show_settings)
	button("Credits & scope",show_credits)

func confirm_new(slot: int) -> void:
	if FileAccess.file_exists(State.path_for(slot)) or FileAccess.file_exists(State.path_for(slot)+".bak"):
		modal("Begin a new journey?","This replaces the selected local profile.")
		button("Replace profile %d"%slot,func() -> void: begin(slot))
		button("Keep my journey",show_title)
	else: begin(slot)

func begin(slot: int) -> void:
	journey_active=true
	State.new_journey(slot);load_room("town",State.player_pos)
	modal("The two processions","Prologue · Festival Square")
	content.add_child(label("A drumbeat falters. One banner turns east toward the garden gate; the official procession turns north. Aster raises both hands.\n\n‘No one marches until we can explain the route.’\n\nMira beckons from the cartography house. ‘Start with what the map says about itself.’",14))
	content.add_child(label("Move: WASD / arrows    Speak & inspect: E\nJournal: J    Map: M    Compass: C    Pause: Esc\nStaff: Space after Orin’s gift    Dodge: Q    Run: Shift",12,GOLD))
	button("Step into Brightwater",close_overlay)

func continue_journey(slot: int) -> void:
	if State.load_game(slot):
		journey_active=true
		load_room(State.room_id,State.player_pos,false);mode="menu";close_overlay()
	else:
		modal("This journey could not be read")
		content.add_child(label("Both the save and recovery snapshot were missing or invalid. Other profiles are unaffected."))
		button("Return to title",show_title)

func load_room(id: String, spawn: Vector2, persist: bool = true) -> void:
	if is_instance_valid(world): remove_child(world);world.queue_free()
	world=Node2D.new();add_child(world)
	actors=[];markers=[];hazards=[];crowd=[]
	State.room_id=id
	if not id in State.visited: State.visited.append(id)
	var room: Dictionary=State.book.rooms[id]
	var layout: Dictionary=State.layouts[id]
	var bg:=Sprite2D.new();bg.texture=load("res://assets/"+id+".png");bg.centered=false;bg.z_index=-2;world.add_child(bg)
	for decor in layout.decor:
		var s:=Sprite2D.new();s.texture=load("res://assets/"+decor.asset+".png")
		s.position=Vector2(decor.x,decor.y)-Vector2(0,s.texture.get_height()/2.0)
		s.z_index=int(decor.y);world.add_child(s)
	for box in layout.collision:
		var body:=StaticBody2D.new();var shape:=CollisionShape2D.new();var rect:=RectangleShape2D.new()
		rect.size=Vector2(box[2],box[3]);shape.shape=rect;body.position=Vector2(box[0]+box[2]/2.0,box[1]+box[3]/2.0);body.add_child(shape);world.add_child(body)
	player=PLAYER.new();world.add_child(player);player.position=spawn
	# Imported/corrupt-position recovery never puts the player inside a collider.
	for box in layout.collision:
		if Rect2(box[0]-7,box[1]-7,box[2]+14,box[3]+14).has_point(player.position): player.position=Vector2(450,350)
	camera=Camera2D.new();camera.position=Vector2.ZERO;camera.zoom=Vector2(2.0/3.0,2.0/3.0);camera.limit_left=0;camera.limit_top=0;camera.limit_right=960;camera.limit_bottom=540;player.add_child(camera)
	camera.position_smoothing_enabled=State.settings.motion
	camera.position_smoothing_speed=8
	camera.make_current();camera.reset_smoothing()
	for o in room.objects:
		if o.kind=="npc":
			var s:=Sprite2D.new();s.texture=load("res://assets/"+o.sprite+".png");s.hframes=4;s.vframes=4;s.position=Vector2(o.x,o.y-14);s.z_index=int(o.y);world.add_child(s);actors.append({"sprite":s,"data":o})
		var dot:=Label.new();dot.text="";dot.position=Vector2(o.x-5,o.y-43);dot.z_index=1000;dot.add_theme_font_size_override("font_size",13);dot.add_theme_color_override("font_color",GOLD);world.add_child(dot);markers.append({"label":dot,"data":o})
	for e in room.exits:
		var sign:=Label.new();sign.text="↗";sign.position=Vector2(e.x-8,e.y-24);sign.z_index=1000;sign.add_theme_font_size_override("font_size",20);sign.add_theme_color_override("font_color",Color("fff0b0"));world.add_child(sign)
	if id=="town":
		for i in range(9):
			var s:=Sprite2D.new();s.texture=load("res://assets/"+["red","green","purple","blue"][i%4]+".png");s.hframes=4;s.vframes=4
			s.position=Vector2(320+(i%5)*78,230+(i/5)*140);s.z_index=int(s.position.y+14);world.add_child(s)
			crowd.append({"sprite":s,"home":s.position,"phase":i})
	for h in room.hazards:
		var copy: Dictionary=h.duplicate();copy["stun"]=0.0;hazards.append(copy)
	State.player_pos=player.position
	player.enabled=mode=="explore"
	transition_time=.25
	set_music("ending" if State.has("ending") else "village" if room.theme in ["town","interior"] else "mystery" if room.theme in ["ruins","under"] else "wilds")
	toast(room.description)
	if persist: State.save_game()

func set_music(id: String) -> void:
	if DisplayServer.get_name()=="headless":
		music_id=id;return
	if id==music_id: return
	music_id=id
	var stream: AudioStreamWAV=load("res://assets/"+id+".wav")
	stream.loop_mode=AudioStreamWAV.LOOP_FORWARD
	stream.loop_end=stream.data.size()/2
	music.stream=stream;music.play()

func _process(delta: float) -> void:
	if mode=="explore":t+=delta
	toast_time=maxf(0,toast_time-delta);notice.visible=toast_time>0
	if not is_instance_valid(player): return
	State.player_pos=player.position
	music.volume_db=-16 if State.settings.music else -80
	camera.position_smoothing_enabled=State.settings.motion
	var room: Dictionary=State.book.rooms[State.room_id]
	region_label.text=room.name.split(" · ")[0].to_upper()
	objective_label.text=State.objective()[0]
	vitality_label.text="● ".repeat(State.vitality)+"○ ".repeat(5-State.vitality)
	for m in markers:
		var o: Dictionary=m.data
		m.label.text="✓" if State.has(o.id) else "•" if o.kind=="rest" else "!" if o.kind=="npc" and not State.has(o.get("gift","")) else "◇"
		m.label.modulate.a=.8+.2*sin(t*2) if State.settings.motion else 1.0
	for c in crowd:
		if State.settings.motion and mode=="explore":
			c.sprite.position=c.home+Vector2(sin(t*.25+c.phase)*10,cos(t*.2+c.phase)*6)
			c.sprite.frame=int(t*3+c.phase)%4;c.sprite.z_index=int(c.sprite.position.y+14)
	for actor in actors:
		actor.sprite.frame=(int(t*1.5)%2 if State.settings.motion else 0)
	if mode=="explore":
		State.seconds+=delta
		transition_time=maxf(0,transition_time-delta)
		find_target()
		update_hazards(delta)
	else: prompt.visible=false
	queue_redraw()

func find_target() -> void:
	target={};var best:=45.0
	var room: Dictionary=State.book.rooms[State.room_id]
	for o in room.objects:
		var distance:=player.position.distance_to(Vector2(o.x,o.y))
		if distance<best:
			best=distance;target=o
	for e in room.exits:
		var distance:=player.position.distance_to(Vector2(e.x,e.y))
		if distance<best:
			best=distance;target=e.duplicate();target["kind"]="exit";target["name"]="Travel to "+State.book.rooms[e.to].name
	prompt.visible=not target.is_empty()
	if not target.is_empty(): prompt.text="[%s]  %s"%[OS.get_keycode_string(State.bindings.interact),target.name]

func _unhandled_input(event: InputEvent) -> void:
	if not remap_action.is_empty():
		if event is InputEventKey and event.pressed and not event.echo:
			if event.physical_keycode!=KEY_ESCAPE:
				var used: bool=event.physical_keycode in [KEY_UP,KEY_DOWN,KEY_LEFT,KEY_RIGHT,KEY_SHIFT,KEY_ENTER]
				for a in State.bindings:
					if a!=remap_action and int(State.bindings[a])==event.physical_keycode: used=true
				if used: toast("That key is already assigned."); return
				State.bindings[remap_action]=event.physical_keycode;State.configure_input()
				if journey_active:State.save_game()
			remap_action="";show_settings()
		return
	if event.is_action_pressed("pause") or (mode!="explore" and event.is_action_pressed("ui_cancel")):
		if mode=="explore": show_pause()
		elif mode=="title": pass
		else: close_overlay()
		get_viewport().set_input_as_handled();return
	if mode!="explore": return
	if event.is_action_pressed("interact") and transition_time<=0: interact(target)
	elif event.is_action_pressed("journal"): show_journal()
	elif event.is_action_pressed("map"): show_map()
	elif event.is_action_pressed("compass"): compass()

func interact(o: Dictionary) -> void:
	if o.is_empty(): return
	var need: Array=o.get("need",[])
	if not State.meets(need):
		modal(o.name,"A lead to return to")
		content.add_child(label("Before this can change, follow these leads:",13))
		for id in need:
			if not State.has(id): content.add_child(label("• "+friendly(str(id)),12,GOLD))
		button("Review journal",show_journal);button("Keep exploring",close_overlay);return
	match o.kind:
		"exit":
			load_room(o.to,Vector2(o.spawn[0],o.spawn[1]));close_overlay()
		"npc":
			State.grant(o.id)
			State.grant(o.get("gift",""))
			modal(o.name,"A conversation on the road")
			content.add_child(label(o.text,14))
			button("Ask for my next lead",func() -> void: content.add_child(label(State.objective()[0]+" · "+State.book.rooms[State.objective()[1]].name,12,GOLD)))
			button("Ask an optional Gemini question",func() -> void: ai_screen(o))
			button("Thank you",close_overlay)
		"evidence": State.grant(o.id);show_evidence(o.id)
		"collect":
			State.grant(o.id);modal(o.name,"Discovery")
			content.add_child(label(o.text,14));button("Continue",close_overlay)
		"rest":
			State.vitality=5;State.save_game();toast("Rested · vitality restored · journey saved")
		"puzzle":
			if State.has(o.id):
				modal(o.name,"Restored")
				content.add_child(label("Your work holds. This part of the route is ready.",14));button("Continue",close_overlay)
			else: show_puzzle(o.id)
		"ending":
			State.grant("ending");show_ending()

func friendly(id: String) -> String:
	if State.book.evidence.has(id): return State.book.evidence[id].title
	if State.book.puzzles.has(id): return State.book.puzzles[id].name
	if id.begins_with("paper"): return "Acknowledge paper worksheet "+id.trim_prefix("paper")
	return {"staff":"Wayfinder staff from Orin in the lodge","line":"River line from Tavi at Reedbank","lens":"Mosaic lens from Sela on the terrace","lantern":"Signal lantern from Inez on the coast","mantle":"Wind mantle from the mountain shelter","rescue":"Help the council on the mountain steps","bell_seal":"Coastkeeper fragment on Bell Isle","gull_seal":"Coastkeeper fragment on Gullstone","lantern_seal":"Coastkeeper fragment on Lantern Key"}.get(id,id.capitalize())

func show_evidence(id: String) -> void:
	var e: Dictionary=State.book.evidence[id]
	modal(e.title,e.location+" · "+e.date)
	content.add_child(label(e.text,15))
	content.add_child(label("Recorded by: "+e.source,12,GOLD))
	content.add_child(label("What this cannot establish: "+e.limitation,12,Color("b9d7c1")))
	button("Pin / unpin in journal",func() -> void:
		if id in evidence_pins: evidence_pins.erase(id)
		elif evidence_pins.size()<3: evidence_pins.append(id)
		toast("Journal pins: %d / 3"%evidence_pins.size()))
	button("Return to the road",close_overlay)

func show_puzzle(id: String) -> void:
	current_puzzle=id;hint_level=0;dial_values=[]
	var p: Dictionary=State.book.puzzles[id]
	modal(p.name,"Operate the mechanism · each control cycles through its positions")
	mode="puzzle"
	content.add_child(label(p.text,13))
	for i in range(p.labels.size()):
		dial_values.append(0)
		var b:=button(p.labels[i]+": "+str(p.choices[i][0]),func() -> void: pass)
		b.pressed.connect(func() -> void:
			dial_values[i]=(int(dial_values[i])+1)%p.choices[i].size()
			b.text=p.labels[i]+": "+str(p.choices[i][dial_values[i]]))
	hint_label=label("Adjust the controls, then test the mechanism.",12,GOLD);content.add_child(hint_label)
	var row:=HBoxContainer.new();content.add_child(row)
	button("Test mechanism",test_puzzle,row)
	button("A hint",puzzle_hint,row)
	button("Leave for now",close_overlay,row)

func test_puzzle() -> void:
	if State.solve(current_puzzle,dial_values):
		var name: String=State.book.puzzles[current_puzzle].name
		modal("The mechanism settles",name+" · restored")
		content.add_child(label("The route changes because of what you found. Your journal and journey have been saved.",14))
		button("Continue",close_overlay)
	else: hint_label.text="The mechanism does not settle. Compare the source sequence with each control; no progress has been lost."

func puzzle_hint() -> void:
	hint_level+=1
	var p: Dictionary=State.book.puzzles[current_puzzle]
	if hint_level==1: hint_label.text="Look at the mechanism’s inscription above. It gives a relationship or sequence, not just a list of objects."
	elif hint_level==2: hint_label.text="Check one control at a time against the dated sources or physical conditions. Try the earliest source first."
	else:
		hint_label.text="Recovery help is available if you want the mechanism set from the recorded evidence."
		button("Use recovery assistance",func() -> void:
			dial_values=p.answer.duplicate();test_puzzle())

func show_worksheet(number: int) -> void:
	modal("Paper checkpoint %d / 6"%number,"Your response stays on paper. The game never records or transmits it.")
	mode="worksheet"
	content.add_child(label(State.book.worksheets[number-1],15))
	button("Review collected sources",show_journal)
	button("I have finished writing on paper",func() -> void: State.grant("paper"+str(number));mode="menu";close_overlay())

func show_journal() -> void:
	modal("Liora’s field journal","Sources carry clues — and limits. Pin up to three to compare.")
	content.add_child(label("Current purpose: "+State.objective()[0],13,GOLD))
	var row:=HBoxContainer.new();content.add_child(row)
	button("Sources",show_journal,row);button("Connections",show_connections,row);button("Map",show_map,row)
	var count:=0
	for id in State.book.evidence:
		if State.has(id):
			count+=1
			button(("◆ " if id in evidence_pins else "")+State.book.evidence[id].title,func() -> void: show_evidence(id))
	if count==0: content.add_child(label("Your pages are blank. Start with Mira’s atlas."))
	content.add_child(label("Tools: "+tool_list(),12,GOLD))
	for i in range(1,7):
		if State.has("paper"+str(i)): button("Review worksheet %d"%i,func() -> void:
			modal("Worksheet %d"%i);content.add_child(label(State.book.worksheets[i-1],14));button("Journal",show_journal))

func tool_list() -> String:
	var names: Array=["Brass compass","Field journal"]
	for tool in ["staff","line","lens","lantern","mantle"]:
		if State.has(tool): names.append(tool.capitalize())
	return ", ".join(names)

func show_connections() -> void:
	modal("Lay the sources together","Read the sources side by side before making a connection.")
	if evidence_pins.is_empty(): content.add_child(label("Open a source and pin it here. You can compare up to three at once."))
	for id in evidence_pins:
		var e: Dictionary=State.book.evidence[id]
		content.add_child(label(e.title,14,GOLD));content.add_child(label(e.text+"\nLimit: "+e.limitation,12))
	if evidence_pins.size()>1:
		content.add_child(label("Do these sources agree, explain a change, or expose a copied assumption? Their relationship matters more than their number.",13,GOLD))
	button("Return to sources",show_journal)

func show_map() -> void:
	modal("The wayfinder’s atlas","Travel lines open as your work restores them. Your current location is marked ◆.")
	var chart:=Control.new()
	chart.set_script(load("res://scripts/atlas_map.gd"));content.add_child(chart)
	content.add_child(label("Recommended destination: "+State.book.rooms[State.objective()[1]].name,14,GOLD))
	var room: Dictionary=State.book.rooms[State.room_id]
	content.add_child(label("FROM "+room.name.to_upper(),12,Color("afd3bd")))
	for e in room.exits:
		content.add_child(label("↗ "+State.book.rooms[e.to].name+(" · open" if State.meets(e.need) else " · needs further work"),12))
	content.add_child(label("PLACES YOU HAVE CHARTED",12,GOLD))
	for id in State.visited:
		var text: String=("◆ " if id==State.room_id else "○ ")+State.book.rooms[id].name
		if State.has("beacon") and State.has("sluice"):
			button(text+" · travel",func() -> void: load_room(id,Vector2(450,350));mode="menu";close_overlay())
		else: content.add_child(label(text))
	content.add_child(label("Known hub travel unlocks after the sluice and lighthouse are restored. Walking routes remain available.",11,Color("afd3bd")))

func show_pause() -> void:
	modal("A moment on the road","Profile %d · %d minutes traveled"%[State.profile,int(State.seconds/60)])
	button("Resume",close_overlay);button("Field journal",show_journal);button("World map",show_map)
	button("Controls & accessibility",show_settings)
	button("Save journey",func() -> void: State.save_game())
	button("Return to title",func() -> void: State.save_game();show_title())
	button("Quit game",func() -> void: State.save_game();get_tree().quit())

func show_settings() -> void:
	modal("Travel preferences","Settings apply immediately. Keyboard and standard gamepad controls are supported.")
	for pair in [["gentle","Gentle journey · no vitality loss"],["music","Music"],["motion","Ambient motion & camera smoothing"]]:
		button(pair[1]+(" · on" if State.settings[pair[0]] else " · off"),func() -> void: State.settings[pair[0]]=not State.settings[pair[0]];show_settings())
	button("Optional Gemini connection",connection_settings)
	content.add_child(label("REMAP KEYBOARD · Click an action, then press a new key. Esc cancels.",11,GOLD))
	for action in State.bindings:
		button(action.capitalize()+" · "+OS.get_keycode_string(State.bindings[action]),func() -> void:
			remap_action=action
			toast("Press a key for "+action+". Esc cancels."))
	content.add_child(label("Gamepad: left stick moves; A interacts; X sweeps staff; B dodges; Y opens journal. Menus use directional focus and accept. Shift runs. Arrow keys remain movement alternatives. All puzzle hints have optional recovery assistance.",12))
	button("Back to title",show_title)

func connection_settings() -> void:
	modal("Optional Gemini conversation","The adventure works offline. The key is kept only in memory for this session.")
	content.add_child(label("Paste your Gemini auth key below, or launch Godot with GEMINI_API_KEY set. Only your optional question and already-discovered source excerpts are sent to Google. Paper responses are never entered here.",13))
	var input:=LineEdit.new();input.secret=true;input.placeholder_text="Gemini auth key";input.add_theme_font_size_override("font_size",13);content.add_child(input)
	var model_input:=LineEdit.new();model_input.text=ai.model;content.add_child(model_input)
	button("Use connection for this session",func() -> void:
		ai.key=input.text.strip_edges();ai.model=model_input.text.strip_edges()
		input.text="";toast("Connection configured for this session");show_settings())
	button("Use offline dialogue",func() -> void: ai.key="";ai.cancel();show_settings())

func ai_screen(o: Dictionary) -> void:
	modal("Ask "+o.name,"Optional AI conversation · authored dialogue always remains available")
	content.add_child(label("Ask about discoveries in your journal. Optional replies may be mistaken; they cannot change the story.",12))
	var question:=LineEdit.new();question.placeholder_text="What would you like to ask about the evidence?";question.max_length=500;question.add_theme_font_size_override("font_size",12);content.add_child(question)
	ai_output=label("",13);content.add_child(ai_output)
	button("Ask",func() -> void:
		if ai.busy or question.text.strip_edges().is_empty(): return
		var known: Array=[]
		for id in State.book.evidence:
			if State.has(id): known.append(State.book.evidence[id].text)
		ai_output.text="Considering your question… You can leave at any time."
		ai.ask(o.name,question.text,known))
	button("Return to the road",close_overlay)

func _ai_reply(text: String) -> void:
	if is_instance_valid(ai_output): ai_output.text=text

func show_credits() -> void:
	modal("About this journey","An original compact adaptation of The Sunlit Atlas GDD v2")
	content.add_child(label("Design and narrative foundation: user-provided GDD v2.\nImplementation, pixel assets, and original synthesized music: generated for this project. Optional development dialogue: Google Gemini.\n\nThis build covers the complete central story arc in 20 compact locations. It does not implement the GDD’s 60-sector, 20–30 hour production scope, full schedules, six dungeon complexes, or every optional chain. See docs/SCOPE.md for the exact boundary.",13))
	button("Return to title",show_title)

func show_ending() -> void:
	set_music("ending")
	modal("THE LIVING LINE","Epilogue · A route worth keeping — and revisiting")
	content.add_child(label("From the summit, Liora watches torches bloom along the eastern marks. They cross Silverrun on the public ferry, pass the restored mosaics, and reach Beacon Point.\n\nVarn lowers the old atlas. ‘Then we will maintain this route. And we will write down why.’\n\nThe valley’s light is no longer a claim copied without question. It is a promise tested together.",14))
	var extras:=int(State.has("orchard_story"))+int(State.has("far_story"))+int(State.has("underpath"))
	content.add_child(label("%d optional community discoveries join the celebration.\nYour compass becomes still, then gives one faint pulse toward the islands."%extras,12,GOLD))
	button("Keep exploring the changed valley",close_overlay);button("Return to title",show_title)

func compass() -> void:
	var room: Dictionary=State.book.rooms[State.room_id]
	var nearest: Dictionary={};var distance:=INF
	for o in room.objects:
		if State.has(o.id) or o.kind=="rest": continue
		var d:=player.position.distance_to(Vector2(o.x,o.y))
		if d<distance: distance=d;nearest=o
	if nearest.is_empty():toast("The compass is quiet. Your next lead: "+State.objective()[0]);return
	var vector:=Vector2(nearest.x,nearest.y)-player.position
	var bearing: String=("east" if vector.x>0 else "west") if absf(vector.x)>absf(vector.y) else ("south" if vector.y>0 else "north")
	toast("A warm pulse to the "+bearing+" · "+nearest.name)

func update_hazards(delta: float) -> void:
	for h in hazards:
		h.stun=maxf(0,float(h.stun)-delta)
		var pos:=hazard_pos(h)
		if State.room_id=="copies" and State.has("guardian"): continue
		if player.sweep>0 and player.position.distance_to(pos)<46: h.stun=3.0
		if float(h.stun)>0: continue
		var active:=fmod(t+float(h.x)/100,3.6)>1.4
		if not active: continue
		if State.has("mantle") and h.type=="wind":continue
		if player.position.distance_to(pos)<float(h.radius) and player.hurt_time<=0 and player.dodge_time<=0:
			if State.settings.gentle:continue
			State.vitality-=1;player.hurt_time=1.5
			toast("A glancing hit · dodge the marked danger or use your staff")
			if State.vitality<=0:
				State.vitality=5;player.position=Vector2(220,385);player.hurt_time=3
				State.player_pos=player.position;State.save_game();toast("You recover at the rest point. All discoveries are safe.")

func hazard_pos(h: Dictionary) -> Vector2:
	return Vector2(h.x,h.y)+Vector2(sin(t*.8+float(h.x))*22,cos(t*.7)*10) if h.type=="creature" else Vector2(h.x,h.y)

func _draw() -> void:
	if not is_instance_valid(player):return
	for h in hazards:
		if State.room_id=="copies" and State.has("guardian"):continue
		var pos:=hazard_pos(h)
		var active:=fmod(t+float(h.x)/100,3.6)>1.4
		var c:=Color("ed9c65") if active else Color("f5dd91")
		if float(h.stun)>0:c=Color("91ccb0")
		draw_arc(pos,float(h.radius),0,TAU,20,c,1.0)
		if h.type=="creature":
			draw_rect(Rect2(pos-Vector2(10,13),Vector2(20,12)),Color("ad7446"));draw_rect(Rect2(pos-Vector2(6,16),Vector2(12,5)),Color("c99655"));draw_rect(Rect2(pos+Vector2(5,-11),Vector2(2,2)),Color("273b3a"))
		elif active:draw_line(pos-Vector2(8,8),pos+Vector2(8,8),c,3);draw_line(pos-Vector2(-8,8),pos+Vector2(-8,8),c,3)
	if State.has("ending"):
		for i in range(26):
			var p:=Vector2(180+i*25,280+sin(i*.4)*24)
			draw_circle(p,3,GOLD);draw_line(p,p+Vector2(0,10),Color("9a6a45"),2)

func toast(text: String) -> void:
	if not is_instance_valid(notice):return
	notice.text=text;toast_time=4.5

func _exit_tree() -> void:
	if is_instance_valid(music):
		music.stop()
		music.stream=null
	if is_instance_valid(ai):ai.cancel()

func focus_first() -> void:
	if not is_instance_valid(content):return
	for child in content.get_children():
		if child is Button:
			child.grab_focus();return
