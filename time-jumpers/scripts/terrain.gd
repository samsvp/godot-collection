extends Node3D

const OFFSET_X := 2.2
const OFFSET_Z := 2.2

@export var rows := 8
@export var columns := 12

# sprites
@export var trees: PackedScene
@export var house: PackedScene
@export var mountain: PackedScene

# cubes 
@export var water: PackedScene 
@export var grass_floor: PackedScene

var floor_1 := load("res://time-jumpers/sprites/grass_floor_1.png")
var floor_2 := load("res://time-jumpers/sprites/grass_floor_2.png")

var terrain: Array

enum TileTypes {
	Building,
	Forest,
	Mountain,
	None,
	Water,
}

# Called when the node enters the scene tree for the first time.
func _ready():
	terrain = generate_basic_terrain(rows, columns - 2)
	
	for z in range(columns):
		for x in range(rows):
			create_tile(x, z)


## creates a tile at the given (x, z) position
func create_tile(x: int, z: int) -> void:
	var gf_instance 
	if z == 0 or z == columns - 1 or terrain[z - 1][x] != TileTypes.Water:
		gf_instance = grass_floor.instantiate()
	else:
		gf_instance = water.instantiate()
	gf_instance.mesh.resource_local_to_scene = true
	var position := -Vector3(OFFSET_X * x, 1.0, OFFSET_Z * z)
	gf_instance.position = position
	gf_instance.name = "block_%s_%s" % [
		-int(gf_instance.position.x), 
		-int(gf_instance.position.z)
	]
	
	if z != 0 and z != columns - 1 and terrain[z - 1][x] == TileTypes.Water:
		pass
	elif (x + z % 2) % 2 == 0:
		gf_instance.get_active_material(0).albedo_texture = floor_1
	else:
		gf_instance.get_active_material(0).albedo_texture = floor_2
	add_child(gf_instance)
	
	if z == 0 or z == columns - 1 or terrain[z - 1][x] == TileTypes.None:
		return
	
	var instance
	if terrain[z - 1][x] == TileTypes.Forest:
		instance = trees.instantiate()
	elif terrain[z - 1][x] == TileTypes.Building:
		instance = house.instantiate()
	elif terrain[z - 1][x] == TileTypes.Mountain:
		instance = mountain.instantiate()
	else:
		return
	instance.position = Vector3(0, 2, 0)
	gf_instance.add_child(instance)


## Generates a random basic terrain (a terrain with only mountains, water,
## buildings and florests).
## The algorithm uses the following rules:
## Water has a higher chance of spawning close to water; 
## Forests and Buildings are spawned randomly;
## Mountains are spawned near the borders and are generally close together;
## Returns an Array[Array[TileTypes]]
func generate_basic_terrain(size_x: int, size_y: int) -> Array:
	var terrain := []
	var available_spots: PackedVector2Array = []
	
	## picks a random spot and assign it to the given tile.
	## returns true if a tyle has been added and false otherwise
	var assign_random_spot := func (type: TileTypes) -> Array:
		var s := available_spots.size()
		if s == 0:
			return [false, null]
		var i := randi_range(0, s - 1)
		var v: Vector2 = available_spots[i]
		terrain[v.y][v.x] = type
		available_spots.remove_at(i)
		return [true, v]
	
	for y in range(size_y):
		terrain.append([])
		for x in range(size_x):
			terrain[y].append(TileTypes.None)
			available_spots.append(Vector2(x, y))
	
	var building_amount: int = round((0.6 * randf() + 0.8) * 0.07 * size_x * size_y)
	for _i in range(building_amount):
		if not assign_random_spot.call(TileTypes.Building)[0]:
			break
	
	# spawn forests randomly
	var tree_amount: int = round((0.6 * randf() + 0.8) * 0.1 * size_x * size_y)
	for _i in range(tree_amount):
		if not assign_random_spot.call(TileTypes.Forest)[0]:
			break
	
	# spawn lakes
	# 0.046875 * 8 * 8 = 3
	var water_amount: int = round((0.6 * randf() + 0.8) * 0.046875 * size_x * size_y)
	for _i in range(water_amount):
		var res: Array =assign_random_spot.call(TileTypes.Water)
		if not res[0]:
			break
		
		var v: Vector2 = res[1]
		while true:
			if randf() > 0.8:
				break
			
			var x_off: int = [-1, 0, 1][randi_range(0, 2)]
			var y_off: int = [-1, 0, 1][randi_range(0, 2)]
			var new_v := Vector2(v.x + x_off, v.y + y_off)
			if new_v.x >= size_x or new_v.y >= size_y or new_v not in available_spots:
				continue
			terrain[new_v.y][new_v.x] = TileTypes.Water
			var i := available_spots.find(new_v)
			available_spots.remove_at(i)
	
	var mountain_amount: int = round((0.6 * randf() + 0.8) * 0.08 * size_x * size_y)
	for _i in range(mountain_amount):
		var x: int = [0, size_x-1][randi_range(0, 1)]
		var y: int = randi_range(0, size_y-1)
		var v := Vector2(x, y)
		if v not in available_spots:
			continue
		while true:
			if v not in available_spots or randf() < 0.2:
				break
			terrain[v.y][v.x] = TileTypes.Mountain
			var i := available_spots.find(v)
			available_spots.remove_at(i)
			v.y += 1
	
	return terrain


func print_terrain(terrain: Array) -> void:
	for t in terrain:
		print(t)
