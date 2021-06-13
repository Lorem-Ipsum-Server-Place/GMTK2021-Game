extends Node2D

const TINY_FLOAT = 0.0000001

var viewports:Array = []
var draw_surfaces:Array = []
var active_viewport: int = 0
var active_level = null

onready var flying_enemy = load("res://FlyingEnemy.tscn")

onready var level_enemies = [
	[flying_enemy],
	[flying_enemy],
]

onready var level1 = load("res://Levels/ConstructedLevels/Level1.tscn")
onready var example_level = load("res://Levels/ConstructedLevels/ExampleLevel.tscn")

onready var level_list = [
	level1,
	example_level
]

signal update_global_weapon_angle(rotation)


func initialise_viewport(viewport: Viewport):
	viewport.usage = Viewport.USAGE_2D
	viewport.own_world = true
	
	var player = load("res://Player.tscn").instance()
	
	if len(viewports) > 0:
		# copy settings from other viewport
		pass
	player.position = Vector2(200,200)
	
	player.connect("damage_player", GameState, "damage_player")
	GameState.connect("player_dead", player, "_on_GameState_player_dead")
	
	viewport.add_child(player)
	viewport.render_target_v_flip = true
	
	var single_level = active_level.instance()
	
	viewport.add_child(single_level)
	
	GameState.connect("weapon_rotation", player, "on_GameState_rotate_sword")

func create_rect(dimensions: Vector2):
	return PoolVector2Array([
		Vector2(0,0),
		Vector2(dimensions.x, 0),
		dimensions,
		Vector2(0, dimensions.y)
	])	

func calculate_viewport_area(viewport_count: int):
	var window_size = get_viewport_rect().size
	# find the first square number after our viewport count. Lets pretend that
	# 4^2 is our limit(not that we'll ever get that many viewports)
	assert( viewport_count > 0 )
	
	var divisor = -1
	
	for i in range(5):
		if pow(i, 2) >= viewport_count:
			divisor = i
			break
	
	# We MUST have found a divisor
	assert( divisor != -1 )
	
	return Vector2(window_size.x / divisor, window_size.y / divisor)

func add_new_viewport():
	var window_size: Vector2 = get_viewport_rect().size
	#loop through existing viewports and surfaces to correct their size
	var viewport_area = calculate_viewport_area(len(viewports) + 1)
	
	# Create Rectangle 
	var display_area = Polygon2D.new()
	draw_surfaces.append(display_area)
	
	var new_viewport = Viewport.new()
	viewports.append(new_viewport)
	
	for v in viewports:
		var viewport = v as Viewport
		viewport.size = viewport_area
	
	for i in range(len(draw_surfaces)):
		var poly_2d = draw_surfaces[i] as Polygon2D
		poly_2d.set_polygon(create_rect(viewport_area))
		poly_2d.position = get_viewport_position(i)
	
	
	new_viewport.size = viewport_area
	
	initialise_viewport(new_viewport)
	
	display_area.texture = new_viewport.get_texture()
	
	
	add_child(new_viewport)
	add_child(display_area)
	

func init_game_state():
	
	connect("update_global_weapon_angle", GameState, "_on_Theatre_update_global_weapon_angle")
	GameState.total_kills = 0
	

func get_viewport_position(index):
	var viewport_count = len(viewports)
	var window_size = get_viewport_rect().size
	
	
	var viewport_area = calculate_viewport_area(viewport_count)
	return Vector2(
			int(index*viewport_area.x) % int(window_size.x),
			floor((index*viewport_area.x)/window_size.x)*viewport_area.y
		)
	
# Called when the node enters the scene tree for the first time.
func _ready():
	
	active_level = level_list[0]
	
	
	init_game_state()
	
	for i in range(GameState.viewport_count):
		add_new_viewport()
	pass
	#var player = load("res://Player.tscn").instance()
	#add_child(player)
	
	
func calculate_weapon_angle():
	var angle = 0
		
	# get viewport info
	var viewport_size = calculate_viewport_area(len(viewports))
	var viewport_position = get_viewport_position(active_viewport)
	
	#get key coordinates
	var centre_of_viewport = viewport_position + (viewport_size / 2)
	var mouse_position = get_viewport().get_mouse_position()
	
	# get delta for working out the angle
	var position_delta = (mouse_position - centre_of_viewport).normalized()
	
	var y_delta = position_delta.y
	if y_delta == 0:
		y_delta = -TINY_FLOAT
	
	# work out the angle to point the weapon away based on our position delta
	angle = atan(position_delta.x / -y_delta)
	# correct the angle if the weapon is pointing down
	if position_delta.y > 0:
		angle += PI
	
	# broadcast the new weapon angle to all players
	emit_signal("update_global_weapon_angle", angle)
	
func _process(delta):
	# figure out which viewport should be active, if any
	var mouse_active_viewport = -1
	var mouse_position = get_viewport().get_mouse_position()
	var viewport_size = calculate_viewport_area(len(viewports))
	
	for i in range(len(viewports)):
		var viewport_position = get_viewport_position(i)
		var viewport_area = Rect2(viewport_position, viewport_size)
		if viewport_area.has_point(mouse_position):
			mouse_active_viewport = i
			break
		
	
	if mouse_active_viewport != -1:
		active_viewport = mouse_active_viewport
		
	# work out the angle based on our active viewport
	calculate_weapon_angle()
	
	
	pass


func _on_timer_add_enemies():
	var viewport_size = calculate_viewport_area(len(viewports))
	for i in range(len(viewports)):
		var viewport = viewports[i] as Viewport
		
		var possible_enemies = level_enemies[i]
		
		var player = get_node_or_null(viewport.get_path() as String + "/Player")
		if player != null and is_instance_valid(player):
			var player_weapon = player.player_weapon
			
			for j in range(GameState.enemy_spawn_count):
				var enemy_to_spawn = possible_enemies[rand_range(0, len(possible_enemies))]
				var enemy_instance = enemy_to_spawn.instance()
				
				var e_graphic = enemy_instance.get_node("EnemyGraphic") as Sprite
				
				var modulation_colour = Color.from_hsv(randf(), .4, 1, 1 )
				
				e_graphic.modulate = modulation_colour
				
				
				
				var player_position = player.position
				var angle = rand_range(-PI, PI)
				
				var normal = Vector2(
					sin(angle),
					cos(angle)
				)
				
				enemy_instance.position = Vector2(
					player_position.x + normal.x*(viewport_size.x/2),
					player_position.y + normal.y*(viewport_size.y/2)
				)
				
				
				print(player_weapon.connect("deal_damage", enemy_instance, "take_damage"))
				viewport.add_child(enemy_instance)
		
		pass
