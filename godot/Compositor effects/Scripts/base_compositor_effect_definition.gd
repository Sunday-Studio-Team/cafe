class_name BaseCompositorEffectDefinition
extends Resource

@export_file_path var shader_file_path: String

var ObjectShader: RID
var EffectCallbackStage: CompositorEffect.EffectCallbackType

var cached_uniform_set: RID
var cached_texture_rid: RID

var compute_pipeline: RID

func SetAndReturnEffectCallbackStage() -> CompositorEffect.EffectCallbackType:
	EffectCallbackStage = CompositorEffect.EFFECT_CALLBACK_TYPE_POST_TRANSPARENT

	return EffectCallbackStage

func Initialize():
	return

# the ref counted object should not contain the rendering device to avoid use after frees from rogue destructors
func LoadShader(ObjectRenderingDevice) -> void:
	if !ObjectRenderingDevice:
		print("Unable to get RenderingDevice from RenderingServer.")
		return
	if(!shader_file_path):
		print("Shader file not provided.")
		return
	var shader_file: RDShaderFile = load(shader_file_path)
	var shader_spirv: RDShaderSPIRV = shader_file.get_spirv()
	ObjectShader = ObjectRenderingDevice.shader_create_from_spirv(shader_spirv)
	compute_pipeline = ObjectRenderingDevice.compute_pipeline_create(ObjectShader)

func CreateAndCacheRIDIfChanged(TargetRenderImage: RID, ParameterRenderingDevice: RenderingDevice):
	# technically this is faster than an include guard because GDScript's optimization passes are next to nonexistent
	if(!cached_uniform_set || cached_texture_rid != TargetRenderImage):
		cached_texture_rid = TargetRenderImage

		var uniform_set := RDUniform.new()
		uniform_set.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
		uniform_set.binding = 0
		uniform_set.add_id(TargetRenderImage)

		cached_uniform_set = ParameterRenderingDevice.uniform_set_create([uniform_set], Shader, 0)

func DispatchWarp(Computelist: int, ObjectRenderingDevice: RenderingDevice, RenderSceneBufferSize: Vector2i):
	if(!cached_uniform_set):
		return

	ObjectRenderingDevice.compute_list_bind_uniform_set(Computelist, cached_uniform_set, 0)

	# wasted cycles just converting it. should use normalized integer division instead
	var x_warp_group_size := int(ceil(float(RenderSceneBufferSize.x) / 8))
	var y_warp_group_size := int(ceil(float(RenderSceneBufferSize.y) / 8))
	ObjectRenderingDevice.compute_list_dispatch(Computelist, x_warp_group_size, y_warp_group_size, 1)
	ObjectRenderingDevice.compute_list_add_barrier(Computelist)
