@tool
class_name Block
extends Resource

@export var texture: Texture2D
@export var textureSide: Texture2D
@export var textureTop: Texture2D
@export var textureBottom: Texture2D
@export var textureFront: Texture2D
@export var textureBack: Texture2D
@export var textureRight: Texture2D
@export var textureLeft: Texture2D

@export var name: String

func getTextures() -> Array[Texture2D]:
	return [texture, textureSide, textureTop, textureBottom, textureFront, textureBack, textureRight, textureLeft]
