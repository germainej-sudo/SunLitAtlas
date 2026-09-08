extends Node2D

const GRASS_DARK = Color("5f9e55")
const GRASS_LIGHT = Color("8fc76a")
const FLOWER_WHITE = Color("f8edce")
const FLOWER_GOLD = Color("f6d477")
const FLOWER_CORAL = Color("df796d")
const PLAZA_DARK = Color("c9b77b")
const PLAZA_LIGHT = Color("ead99a")

var grass_zones: Array[Rect2] = [
	Rect2(40, 80, 700, 300),
	Rect2(40, 560, 700, 450),
	Rect2(1500, 80, 600, 340),
	Rect2(1500, 650, 600, 380)
]

var plaza_zones: Array[Rect2] = [
	Rect2(790, 365, 700, 500),
	Rect2(1490, 430, 470, 360)
]

func _ready() -> void:
	z_index = -1
	queue_redraw()

func _draw() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 741903
	for zone in grass_zones:
		var count := maxi(8, int(zone.size.x * zone.size.y / 14500.0))
		for i in range(count):
			var p := Vector2(
				roundf(zone.position.x + rng.randf() * zone.size.x),
				roundf(zone.position.y + rng.randf() * zone.size.y)
			)
			var shade := GRASS_LIGHT if i % 3 == 0 else GRASS_DARK
			draw_rect(Rect2(p, Vector2(1, 3)), shade)
			draw_rect(Rect2(p + Vector2(1, 1), Vector2(1, 2)), shade.darkened(0.08))
			if i % 7 == 0:
				var bloom := [FLOWER_WHITE, FLOWER_GOLD, FLOWER_CORAL][i % 3]
				draw_rect(Rect2(p + Vector2(-1, -1), Vector2(1, 1)), bloom)
				draw_rect(Rect2(p + Vector2(1, -1), Vector2(1, 1)), bloom)
				draw_rect(Rect2(p + Vector2(0, -2), Vector2(1, 1)), bloom)
	for zone in plaza_zones:
		var count := maxi(10, int(zone.size.x * zone.size.y / 12000.0))
		for i in range(count):
			var p := Vector2(
				roundf(zone.position.x + rng.randf() * zone.size.x),
				roundf(zone.position.y + rng.randf() * zone.size.y)
			)
			var length := rng.randi_range(2, 5)
			var shade := PLAZA_LIGHT if i % 5 == 0 else PLAZA_DARK
			draw_rect(Rect2(p, Vector2(length, 1)), shade)
			if i % 4 == 0:
				draw_rect(Rect2(p + Vector2(length - 1, 1), Vector2(1, 2)), shade.darkened(0.07))
