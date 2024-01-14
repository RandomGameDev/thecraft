@tool
class_name BlockManager
extends Node

@export var air: Block
@export var stone: Block
@export var dirt: Block
@export var grass: Block

var atlasLookup = {}

var gridWidth := 4
var gridHeight: int

var blockTextureSize := Vector2i(160, 160)
var textureAtlasSize: Vector2i

static var instance: BlockManager
var chunkMaterial: StandardMaterial3D

# Called when the node enters the scene tree for the first time.
func _ready():
	instance = self
	
	var blockTextures = [air, stone, dirt, grass].filter(func(block): return block != null).map(func(block): return block.getTextures()).reduce(func(accum, textureSet): return (textureSet.reduce(func(accum2, texture): return (texture + accum if texture != null else accum))) + accum ,[])
	#.filter(func(texture): return texture != null)
	print("boa", blockTextures)
	
	
	for blockTextureIndex in range(blockTextures.size()):
		var blockTexture = blockTextures[blockTextureIndex]
		#printt("ABC", blockTexture)
		atlasLookup[blockTexture] = Vector2i(blockTextureIndex % gridWidth, floori(blockTextureIndex / gridWidth))
		
	#printt("TA", atlasLookup)
		
	gridHeight = ceili(blockTextures.size() / float(gridWidth))
	
	var image = Image.create(gridWidth * blockTextureSize.x, gridHeight * blockTextureSize.y, false, Image.FORMAT_RGBA8)
	
	for x in range(gridWidth):
		for y in range(gridHeight):
			var imgIndex = x + y * gridWidth
			
			if imgIndex >= blockTextures.size():
				continue
				
			var currentImage = blockTextures[imgIndex].get_image()
			currentImage.convert(Image.FORMAT_RGBA8)
			
			image.blit_rect(currentImage, Rect2i(Vector2i.ZERO, blockTextureSize), Vector2i(x, y) * blockTextureSize)
			
	var textureAtlas = ImageTexture.create_from_image(image)
	image.save_webp("user://sample.webp")
	
	chunkMaterial = StandardMaterial3D.new()
	chunkMaterial.albedo_texture = textureAtlas
	chunkMaterial.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	
	textureAtlasSize = Vector2(gridWidth, gridHeight)

	
func getTextureAtlasPosition(texture: Texture2D) -> Vector2i:
	if not texture:
		return Vector2i.ZERO
	else:
		return atlasLookup[texture]
