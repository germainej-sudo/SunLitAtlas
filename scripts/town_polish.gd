extends Node

const DETAIL_LAYER = preload("res://scripts/town_detail_layer.gd")
const CREAM = Color("f8edce")
const GOLD = Color("f6d477")
const TEAL = Color("103d43")

var active_room := ""
var active_scene_id := 0
var town_clock := 0.0
var spawned: Array = []
var bound_crowd: Array = []
var role_label: Label
var role_info: Dictionary = {}
var player_node: CharacterBody2D

var key_npcs := {
	"town": {"name": "Aster Finch", "role": "Festival coordinator", "position": Vector2(720, 760)},
	"cartography": {"name": "Mira Vale", "role": "Cartographer", "position": Vector2(395, 270)},
	"hall": {"name": "Councilor Varn", "role": "Councilor and road steward", "position": Vector2(585, 300)},
	"lodge": {"name": "Orin Moss", "role": "Ranger", "position": Vector2(390, 280)},
	"river": {"name": "Tavi Reed", "role": "Riverkeeper", "position": Vector2(320, 300)},
	"ruins": {"name": "Sela Marr", "role": "Archive conservator", "position": Vector2(370, 275)},
	"coast": {"name": "Inez Sol", "role": "Lighthouse keeper", "position": Vector2(350, 300)}
}

var crowd_profiles := [
	{"source": Vector2(350, 380), "home": Vector2(320, 390), "job": "Garden tender", "behavior": "worker", "axis": Vector2(1, 0), "range": 13.0, "speed": 0.75, "phase": 0.2},
	{"source": Vector2(520, 390), "home": Vector2(555, 430), "job": "Groundskeeper", "behavior": "worker", "axis": Vector2(0, 1), "range": 12.0, "speed": 0.65, "phase": 1.4},
	{"source": Vector2(560, 710), "home": Vector2(505, 700), "job": "Festival decorator", "behavior": "festival", "axis": Vector2(1, 0), "range": 24.0, "speed": 0.55, "phase": 2.1},
	{"source": Vector2(630, 790), "home": Vector2(650, 835), "job": "Festival steward", "behavior": "festival", "axis": Vector2(0, 1), "range": 20.0, "speed": 0.50, "phase": 0.8},
	{"source": Vector2(790, 700), "home": Vector2(840, 650), "job": "Resident", "behavior": "walker", "axis": Vector2(1, 0), "range": 55.0, "speed": 0.38, "phase": 0.0},
	{"source": Vector2(830, 805), "home": Vector2(900, 820), "job": "Resident", "behavior": "walker", "axis": Vector2(0, 1), "range": 44.0, "speed": 0.34, "phase": 1.7},
	{"source": Vector2(1030, 460), "home": Vector2(1050, 500), "job": "Plaza walker", "behavior": "walker", "axis": Vector2(1, 0), "range": 66.0, "speed": 0.31, "phase": 2.6},
	{"source": Vector2(1280, 450), "home": Vector2(1340, 500), "job": "Plaza walker", "behavior": "walker", "axis": Vector2(0, 1), "range": 48.0, "speed": 0.36, "phase": 0.5},
	{"source": Vector2(1450, 690), "home": Vector2(1510, 650), "job": "Market courier", "behavior": "courier", "range": 72.0, "range_y": 24.0, "speed": 0.28, "phase": 1.0},
	{"source": Vector2(1690, 710), "home": Vector2(1775, 750), "job": "Market vendor", "behavior": "vendor", "range": 0.0, "speed": 0.55, "phase": 0.0},
	{"source": Vector2(1780, 865), "home": Vector2(1940, 750), "job": "Market vendor", "behavior": "vendor", "range": 0.0, "speed": 0.52, "phase": 1.0},
	{"source": Vector2(1980, 720), "home": Vector2(2050, 780), "job": "Resident", "behavior": "walker", "axis": Vector2(1, 0), "range": 42.0, "speed": 0.30, "phase": 2.2}
]

var extra_decor := [
	{"asset": "flowers", "position": Vector2(780, 555)},
	{"asset": "flowers", "position": Vector2(780, 865)},
	{"asset": "flowers", "position": Vector2(1570, 555)},
	{"asset": "flowers", "position": Vector2(1570, 845)},
	{"asset": "flowers", "position": Vector2(1740, 690)},
	{"asset": "flowers", "position": Vector2(2040, 690)},
	{"asset": "bench", "position": Vector2(825, 875)},
	{"asset": "bench", "position": Vector2(1625, 825)}
]

func _ready() -> void:
	process_priority = 100

func _process(delta: float) -> void:
	var scene := get_tree().current_scene
	if scene == null:
		return
	var room := str(State.room_id)
	var scene_id := scene.get_instance_id()
	if room != active_room or scene_id != active_scene_id:
		_clear_room_additions()
		active_room = room
		active_scene_id = scene_id
		town_clock = 0.0
		_build_room(scene)
	if active_room == "town":
		town_clock += delta
		_update_town_crowd()
	_update_role_label()

func _build_room(scene: Node) -> void:
	player_node = _find_player(scene)
	if active_room == "town":
		var details := DETAIL_LAYER.new()
		scene.add_child(details)
		spawned.append(details)
		_add_extra_decor(scene)
		_bind_town_crowd(scene)
	_build_role_label(scene)

func _clear_room_additions() -> void:
	for node in spawned:
		if is_instance_valid(node):
			node.queue_free()
	spawned.clear()
	bound_crowd.clear()
	role_label = null
	role_info = {}
	player_node = null

func _add_extra_decor(scene: Node) -> void:
	for item in extra_decor:
		var texture: Texture2D = load("res://assets/" + str(item.asset) + ".png")
		if texture == null:
			continue
		var sprite := Sprite2D.new()
		sprite.texture = texture
		var p: Vector2 = item.position
		sprite.position = p - Vector2(0, texture.get_height() / 2.0)
		sprite.z_index = int(p.y)
		scene.add_child(sprite)
		spawned.append(sprite)

func _bind_town_crowd(scene: Node) -> void:
	var candidates := _colored_sprites(scene)
	var used := {}
	for profile in crowd_profiles:
		var best: Sprite2D = null
		var best_distance := 34.0
		var source: Vector2 = profile.source
		for candidate in candidates:
			if used.has(candidate.get_instance_id()):
				continue
			var distance := candidate.position.distance_to(source)
			if distance < best_distance:
				best = candidate
				best_distance = distance
		if best != null:
			used[best.get_instance_id()] = true
			best.position = profile.home
			bound_crowd.append({"sprite": best, "profile": profile})

func _colored_sprites(root: Node) -> Array:
	var found: Array = []
	for child in root.get_children():
		if child is Sprite2D and child.texture != null:
			var path := child.texture.resource_path
			if path.ends_with("/red.png") or path.ends_with("/green.png") or path.ends_with("/purple.png") or path.ends_with("/blue.png"):
				found.append(child)
		found.append_array(_colored_sprites(child))
	return found

func _update_town_crowd() -> void:
	var motion_on := bool(State.settings.get("motion", true))
	for item in bound_crowd:
		var sprite: Sprite2D = item.sprite
		if not is_instance_valid(sprite):
			continue
		var profile: Dictionary = item.profile
		var home: Vector2 = profile.home
		if not motion_on:
			sprite.position = home
			sprite.frame = 0
			sprite.z_index = int(home.y + 14)
			continue
		var phase := town_clock * float(profile.speed) + float(profile.phase)
		var behavior := str(profile.behavior)
		var position := home
		var velocity_hint := Vector2.ZERO
		match behavior:
			"vendor":
				position += Vector2(0, sin(phase) * 1.5)
				velocity_hint = Vector2.ZERO
			"courier":
				var range_x := float(profile.range)
				var range_y := float(profile.range_y)
				position += Vector2(sin(phase) * range_x, cos(phase * 0.7) * range_y)
				velocity_hint = Vector2(cos(phase) * range_x, -sin(phase * 0.7) * range_y * 0.7)
			_:
				var axis: Vector2 = profile.axis
				var travel := float(profile.range)
				position += axis * sin(phase) * travel
				velocity_hint = axis * cos(phase)
		sprite.position = position
		sprite.z_index = int(position.y + 14)
		_animate_crowd_sprite(sprite, velocity_hint, behavior, float(profile.phase))

func _animate_crowd_sprite(sprite: Sprite2D, velocity_hint: Vector2, behavior: String, phase_offset: float) -> void:
	if behavior == "vendor":
		sprite.frame = int(town_clock * 1.2 + phase_offset) % 2
		return
	if velocity_hint.length() < 0.01:
		sprite.frame = 0
		return
	var direction := 0
	if absf(velocity_hint.x) > absf(velocity_hint.y):
		direction = 1 if velocity_hint.x > 0 else 2
	else:
		direction = 0 if velocity_hint.y > 0 else 3
	var pace := int(town_clock * 5.0 + phase_offset * 2.0) % 4
	sprite.frame = direction * 4 + pace

func _build_role_label(scene: Node) -> void:
	if not key_npcs.has(active_room):
		return
	role_info = key_npcs[active_room]
	role_label = Label.new()
	role_label.text = str(role_info.name) + "\n" + str(role_info.role)
	role_label.position = role_info.position + Vector2(-60, -62)
	role_label.size = Vector2(120, 32)
	role_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	role_label.add_theme_font_size_override("font_size", 8)
	role_label.add_theme_color_override("font_color", CREAM)
	role_label.add_theme_color_override("font_outline_color", TEAL)
	role_label.add_theme_constant_override("outline_size", 2)
	role_label.z_index = 4096
	role_label.visible = false
	scene.add_child(role_label)
	spawned.append(role_label)

func _update_role_label() -> void:
	if not is_instance_valid(role_label):
		return
	if not is_instance_valid(player_node):
		player_node = _find_player(get_tree().current_scene)
	if not is_instance_valid(player_node):
		role_label.visible = false
		return
	if not bool(player_node.get("enabled")):
		role_label.visible = false
		return
	var distance := player_node.position.distance_to(role_info.position)
	role_label.visible = distance < 112.0
	if role_label.visible:
		role_label.modulate.a = clampf((132.0 - distance) / 35.0, 0.72, 1.0)

func _find_player(root: Node) -> CharacterBody2D:
	if root == null:
		return null
	for node in root.find_children("*", "CharacterBody2D", true, false):
		if node.get_script() != null and str(node.get_script().resource_path).ends_with("/player.gd"):
			return node as CharacterBody2D
	return null
