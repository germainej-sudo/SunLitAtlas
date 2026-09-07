extends Control
var points: Dictionary={"town":Vector2(70,100),"forest":Vector2(172,67),"river":Vector2(200,140),"ruins":Vector2(285,90),"coast":Vector2(380,135),"bell":Vector2(455,47),"gull":Vector2(494,85),"lantern":Vector2(474,128),"orchard":Vector2(495,167),"far":Vector2(516,18),"mountain":Vector2(62,40),"summit":Vector2(145,18),"under":Vector2(280,165)}
func _ready() -> void:
	custom_minimum_size=Vector2(535,190)
	mouse_filter=Control.MOUSE_FILTER_IGNORE
func _draw() -> void:
	draw_style_box(_paper(),Rect2(Vector2.ZERO,size))
	for id in points:
		if not id in State.visited:continue
		for e in State.book.rooms[id].exits:
			if points.has(e.to) and e.to in State.visited:draw_line(points[id],points[e.to],Color("aaad86"),2)
	for id in points:
		if not id in State.visited:continue
		var pos: Vector2=points[id]
		draw_circle(pos,7,Color("26747a") if id!=State.room_id else Color("d77b4d"))
		var name: String={"town":"Brightwater","forest":"Sunleaf","river":"Silverrun","ruins":"Mosaic","coast":"Beacon","mountain":"Wind Gardens","summit":"Sunspire","bell":"Bell","gull":"Gullstone","lantern":"Lantern","orchard":"Orchard","far":"Far Beacon","under":"Underpath"}[id]
		draw_string(ThemeDB.fallback_font,pos+Vector2(-name.length()*2.4,18),name,HORIZONTAL_ALIGNMENT_LEFT,-1,10,Color("294c47"))
func _paper() -> StyleBoxFlat:
	var s:=StyleBoxFlat.new();s.bg_color=Color("e0d6ab");s.set_corner_radius_all(4);return s
