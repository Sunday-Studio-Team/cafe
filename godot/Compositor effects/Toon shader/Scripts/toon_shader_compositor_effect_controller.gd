@tool
class_name CompositorEffectController
extends CompositorEffect

var rendering_device: RenderingDevice

var cached_uniform_set: RID
var cached_texture_rid: RID

var compute_pipeline: RID
var compiled_shader: RID

var is_setup_phase = true

@export_file_path var shader_file_path: String

func _init() -> void:
	rendering_device = RenderingServer.get_rendering_device()
	# add more callbacks as needed
	effect_callback_type = EFFECT_CALLBACK_TYPE_POST_TRANSPARENT


func load_shader() -> void:
	if !rendering_device:
		print("Unable to get RenderingDevice from RenderingServer.")
		return
	if(!shader_file_path):
		print("Shader file not provided.")
		return
	var shader_file: RDShaderFile = load(shader_file_path)
	var shader_spirv: RDShaderSPIRV = shader_file.get_spirv()

	var compiler_error := shader_spirv.get_stage_compile_error(RenderingDevice.SHADER_STAGE_COMPUTE)
	if(!compiler_error.is_empty()):
		printerr("Failed to compile compute .glsl file with error: \n", compiler_error)
		return

	compiled_shader = rendering_device.shader_create_from_spirv(shader_spirv)
	compute_pipeline = rendering_device.compute_pipeline_create(compiled_shader)


func _render_callback(ParameterEffectCallbackType: int, ParameterRenderData: RenderData) -> void:
	# this node does not have _ready(), so we have to jury rig
	# it like this. This is to allow you to select the
	# shader in the inspector instead of preloading it
	if(is_setup_phase):
		is_setup_phase = false
		load_shader()

	if(ParameterEffectCallbackType != effect_callback_type || !rendering_device || !compute_pipeline.is_valid()):
		return

	var render_scene_buffers: RenderSceneBuffersRD = ParameterRenderData.get_render_scene_buffers()
	if !render_scene_buffers:
		print("Unable to get render scene buffers.")
		return

	var render_scene_buffers_size := render_scene_buffers.get_internal_size()
	if(render_scene_buffers_size.x == 0 || render_scene_buffers_size.y == 0):
		return

	var target_render_image := render_scene_buffers.get_color_layer(0)

	if(!cached_uniform_set || cached_texture_rid != target_render_image):
		cached_texture_rid = target_render_image

		var uniform_set := RDUniform.new()
		uniform_set.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
		uniform_set.binding = 0
		uniform_set.add_id(target_render_image)

		cached_uniform_set = rendering_device.uniform_set_create([uniform_set], compiled_shader, 0)

	var compute_list := rendering_device.compute_list_begin()
	rendering_device.compute_list_bind_compute_pipeline(compute_list, compute_pipeline)

	rendering_device.compute_list_bind_uniform_set(compute_list, cached_uniform_set, 0)

	# wasted cycles just converting it. should use normalized integer division instead
	var x_warp_group_size := int(ceil(float(render_scene_buffers_size.x) / 8))
	var y_warp_group_size := int(ceil(float(render_scene_buffers_size.y) / 8))
	rendering_device.compute_list_dispatch(compute_list, x_warp_group_size, y_warp_group_size, 1)

	rendering_device.compute_list_end()
