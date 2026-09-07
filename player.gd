extends CharacterBody2D
var enabled: bool = false
var direction: int = 0
var clock: float = 0
var hurt_time: float = 0
var sweep: float = 0
var dodge_time: float = 0
var cooldown: float = 0
var facing := Vector2.DOWN
var walk := Vector2.ZERO
var sprite: Sprite2D

func _ready() -> void:
	var collider := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 6
	collider.shape = shape
	collider.position = Vector2(0,-4)
	add_child(collider)
	sprite = Sprite2D.new()
	sprite.texture = preload("res://assets/liora.png")
	sprite.hframes = 4; sprite.vframes = 4
	sprite.position = Vector2(0,-14)
	add_child(sprite)

func _physics_process(delta: float) -> void:
	if not enabled:
		velocity = Vector2.ZERO
		return
	clock += delta
	hurt_time = maxf(0,hurt_time-delta)
	sweep = maxf(0,sweep-delta)
	cooldown = maxf(0,cooldown-delta)
	dodge_time = maxf(0,dodge_time-delta)
	walk = Input.get_vector("left","right","up","down")
	if Input.get_connected_joypads().size()>0:
		var joy := Input.get_connected_joypads()[0]
		var stick := Vector2(Input.get_joy_axis(joy,JOY_AXIS_LEFT_X),Input.get_joy_axis(joy,JOY_AXIS_LEFT_Y))
		if stick.length()>.22: walk = stick.limit_length()
	if walk.length()>.1:
		facing = walk.normalized()
		direction = (1 if facing.x>0 else 2) if absf(facing.x)>absf(facing.y) else (0 if facing.y>0 else 3)
	if Input.is_action_just_pressed("dodge") and cooldown<=0:
		dodge_time = .18; cooldown = .75
	if Input.is_action_just_pressed("staff") and State.has("staff"): sweep = .22
	var speed := 100.0 if not Input.is_physical_key_pressed(KEY_SHIFT) else 140.0
	velocity = facing * 260 if dodge_time>0 else walk*speed
	move_and_slide()
	position.x = clampf(position.x,24,936)
	position.y = clampf(position.y,65,514)
	z_index = int(position.y)
	sprite.frame = direction*4 + (int(clock*9)%4 if walk.length()>.1 else 0)
	sprite.modulate.a = .4 if hurt_time>0 and int(clock*12)%2==0 else 1.0
	queue_redraw()

func _draw() -> void:
	if sweep>0:
		draw_arc(Vector2(0,-10),24,facing.angle()-1.2,facing.angle()+1.2,12,Color("ffe18b"),3)
	if dodge_time>0: draw_arc(Vector2(0,-6),11,0,TAU,16,Color("b2eee0"),1)
