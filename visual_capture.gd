extends Node
var game: Node
func _ready() -> void:
	run.call_deferred()
func snap(name: String) -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://docs/"+name+".png")
func run() -> void:
	State.save_enabled=false;State.new_journey(3)
	game=load("res://scenes/main.tscn").instantiate();add_child(game)
	await snap("title-preview")
	game.journey_active=true;game.mode="menu";game.close_overlay();game.toast_time=0
	await snap("brightwater-preview")
	game.interact(State.book.rooms.cartography.objects.filter(func(o: Dictionary) -> bool:return o.id=="mira")[0])
	await snap("dialogue-preview")
	game.mode="menu";game.close_overlay()
	game.load_room("forest",Vector2(450,350),false);game.toast_time=0
	await snap("sunleaf-preview")
	game.show_puzzle("copies")
	await snap("puzzle-preview")
	game.mode="menu";game.close_overlay()
	State.visited=State.book.rooms.keys();game.show_map()
	await snap("map-preview")
	game.mode="menu";game.close_overlay()
	game.load_room("coast",Vector2(450,350),false);game.toast_time=0
	await snap("coast-preview")
	game.show_ending()
	await snap("ending-preview")
	print("VISUAL: eight rendered screens captured")
	game.queue_free();await get_tree().process_frame
	get_tree().quit()
