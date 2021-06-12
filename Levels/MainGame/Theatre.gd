extends Node2D

var viewports:Array = []
var draw_surfaces:Array = []

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


func initialise_viewport(viewport: Viewport):
	viewport.usage = Viewport.USAGE_2D
	viewport.own_world = true
	
	var player = load("res://Player.tscn").instance()
	
	if len(viewports) > 0:
		# copy settings from other viewport
		pass
	player.position = Vector2(200,200)
	viewport.add_child(player)
	viewport.render_target_v_flip = true

func create_rect(dimensions: Vector2):
	return PoolVector2Array([
		Vector2(0,0),
		Vector2(dimensions.x, 0),
		dimensions,
		Vector2(0, dimensions.y)
	])	

func calculate_viewport_area(viewport_count: int):
	var window_size = get_viewport_rect().size
	# we work in multiples of 2, so we want to log,2 to find out how many times
	# to divide
	
	assert( viewport_count > 0 )
	
	
	var log2_viewport_count = ceil( log(viewport_count)/log(4) )
	print(log2_viewport_count)
	
	return Vector2(window_size.x / pow(2, log2_viewport_count), window_size.y / pow(2, log2_viewport_count))

func add_new_viewport():
	var window_size: Vector2 = get_viewport_rect().size
	#loop through existing viewports and surfaces to correct their size
	var viewport_area = calculate_viewport_area(len(viewports) + 1)
	
	# Create Rectangle 
	var display_area = Polygon2D.new()
	draw_surfaces.append(display_area)
	
	
	for v in viewports:
		var viewport = v as Viewport
		viewport.size = viewport_area
	
	for i in range(len(draw_surfaces)):
		var poly_2d = draw_surfaces[i] as Polygon2D
		poly_2d.set_polygon(create_rect(viewport_area))
		poly_2d.position = Vector2(
			int(i*viewport_area.x) % int(window_size.x),
			floor((i*viewport_area.x)/window_size.x)*viewport_area.y
		)
	
	print(calculate_viewport_area(len(viewports) + 1))
	
	
	var viewport = Viewport.new()
	viewport.size = viewport_area
	viewports.append(viewport)
	
	initialise_viewport(viewport)
	
	display_area.texture = viewport.get_texture()
	
	
	add_child(viewport)
	add_child(display_area)
	

# Called when the node enters the scene tree for the first time.
func _ready():
	add_new_viewport()
	add_new_viewport()
	add_new_viewport()
	pass
	#var player = load("res://Player.tscn").instance()
	#add_child(player)
	
	
#func _process(delta):
	#$Polygon2D.update()



		
