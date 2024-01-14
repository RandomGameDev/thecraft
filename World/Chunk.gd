@tool
extends StaticBody3D

@export var collisionShape: CollisionShape3D  
@export var meshInstance: MeshInstance3D
@export var noise: FastNoiseLite

var dimensions := Vector3i(16, 64, 16)
var vertices := PackedVector3Array([
	Vector3i(0,0,0),
	Vector3i(1,0,0),
	Vector3i(0,1,0),
	Vector3i(1,1,0),
	Vector3i(0,0,1),
	Vector3i(1,0,1),
	Vector3i(0,1,1),
	Vector3i(1,1,1),
])

var topFace := [2,3,7,6]
var bottomFace := [0,4,5,1]
var leftFace := [6,4,0,2]
var rightFace := [3,1,5,7]
var backFace := [7,5,4,6]
var frontFace := [2,0,1,3]

var st = SurfaceTool.new()

var blocks = {}

var chunkPosition: Vector2i

# Called when the node enters the scene tree for the first time.
func _ready():
	chunkPosition = Vector2i(floori(global_position.x / dimensions.x), floori(global_position.z / dimensions.z))
	
	generate()
	update()


func generate():
	for x in range(dimensions.x):
		for y in range(dimensions.y):
			for z in range(dimensions.z):
				var block = Block.new()
				
				var globalBlockPos = chunkPosition * Vector2i(dimensions.x, dimensions.z) + Vector2i(x, z)
				var groundHeight = int(dimensions.y * ((noise.get_noise_2d(globalBlockPos.x, globalBlockPos.y) + float(1)) / float(2)))
				
				#printt("a", groundHeight, y)
				
				if y < groundHeight / 2:
					block = BlockManager.instance.stone
				elif y < groundHeight:
					block = BlockManager.instance.dirt
				elif y == groundHeight:
					block = BlockManager.instance.grass
				else:
					block = BlockManager.instance.air
				
				blocks[Vector3i(x,y,z)] = block

func update():
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for x in range(dimensions.x):
		for y in range(dimensions.y):
			for z in range(dimensions.z):
				createBlockMesh(Vector3i(x,y,z))
	
	st.set_material(BlockManager.instance.chunkMaterial)
	var mesh = st.commit()
	
	meshInstance.mesh = mesh
	collisionShape.shape = mesh.create_trimesh_shape()
				
func createBlockMesh(blockPosition: Vector3i):
	
	var block = blocks[blockPosition]
	
	if block == BlockManager.instance.air:
		return
	
	if isTransparent(blockPosition + Vector3i.UP):
		createFaceMesh(blockPosition, topFace, block.texture)
	
	if isTransparent(blockPosition + Vector3i.DOWN):
		createFaceMesh(blockPosition, bottomFace, block.texture)
	
	if isTransparent(blockPosition + Vector3i.LEFT):
		createFaceMesh(blockPosition, leftFace, block.texture)

	if isTransparent(blockPosition + Vector3i.RIGHT):
		createFaceMesh(blockPosition, rightFace, block.texture)
	
	if isTransparent(blockPosition + Vector3i.FORWARD):
		createFaceMesh(blockPosition, frontFace, block.texture)
	
	if isTransparent(blockPosition + Vector3i.BACK):
		createFaceMesh(blockPosition, backFace, block.texture)
	
func createFaceMesh(blockPosition: Vector3i, face: Array, texture: Texture2D):
	
	var texturePos = BlockManager.instance.getTextureAtlasPosition(texture)
	#printt("Texture", texturePos)
	var textureAtlasSize = BlockManager.instance.textureAtlasSize
	
	var uvOffset = Vector2(float(texturePos.x) / textureAtlasSize.x, float(texturePos.y) / textureAtlasSize.y)
	var uvWidth = float(1) / textureAtlasSize.x
	var uvHeight = float(1) / textureAtlasSize.y
	
	var uvA = uvOffset + Vector2.ZERO
	var uvB = uvOffset + Vector2(0, uvHeight)
	var uvC = uvOffset + Vector2(uvWidth, uvHeight)
	var uvD = uvOffset + Vector2(uvWidth, 0)
	
	printt("ABC", texturePos / textureAtlasSize, texturePos, textureAtlasSize)
	
	var a = vertices[face[0]] as Vector3i + blockPosition
	var b = vertices[face[1]] as Vector3i + blockPosition
	var c = vertices[face[2]] as Vector3i + blockPosition
	var d = vertices[face[3]] as Vector3i + blockPosition
	
	var uvTri1 = [uvA, uvB, uvC]
	var uvTri2 = [uvA, uvC, uvD]
	
	var tri1 = [a, b, c]
	var tri2 = [a, c, d]
	
	st.add_triangle_fan(tri1, uvTri1)
	st.add_triangle_fan(tri2, uvTri2)
	
func isTransparent(blockPosition: Vector3i) -> bool:
	if blockPosition.x < 0 || blockPosition.x >= dimensions.x: return true
	if blockPosition.y < 0 || blockPosition.y >= dimensions.y: return true
	if blockPosition.z < 0 || blockPosition.z >= dimensions.z: return true
	
	return blocks[blockPosition] == BlockManager.instance.air


