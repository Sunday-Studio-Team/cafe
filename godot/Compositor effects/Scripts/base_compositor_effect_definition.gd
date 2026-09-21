class_name BaseCompositorEffectDefinition
extends RefCounted

var rendering_device: RenderingDevice
@export var shader_file: RDShaderFile

var ObjectShader: RID
var EffectCallbackStage: CompositorEffect.EffectCallbackType 

var cached_uniform_set: RID
var cached_texture_rid: RID

var compute_pipeline: RID

func Initialize() -> void:
	EffectCallbackStage = CompositorEffect.EFFECT_CALLBACK_TYPE_POST_TRANSPARENT
	
	LoadShader()
	
func LoadShader() -> void: 
	if !rendering_device:
		print("Unable to get RenderingDevice from RenderingServer.")
		return
	if(!shader_file):
		print("Toon shader file not provided.")
		return
	var shader_spirv: RDShaderSPIRV = shader_file.get_spirv()
	ObjectShader = rendering_device.shader_create_from_spirv(shader_spirv)
	compute_pipeline = rendering_device.compute_pipeline_create(ObjectShader)

func CreateAndCacheRIDIfChanged(TargetRenderImage: RID, ParameterRenderingDevice: RenderingDevice):
	if(!cached_uniform_set):
		cached_texture_rid = TargetRenderImage
		
		var uniform_set := RDUniform.new()
		uniform_set.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
		uniform_set.binding = 0
		uniform_set.add_id(TargetRenderImage)

		cached_uniform_set = ParameterRenderingDevice.uniform_set_create([uniform_set], Shader, 0)
