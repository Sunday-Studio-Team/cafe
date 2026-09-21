@tool
extends CompositorEffect

var rendering_device: RenderingDevice
@export var toon_shader_file: RDShaderFile

var toon_shader: RID

var cached_uniform_set: RID
var cached_texture_rid: RID

var compute_pipeline: RID

func _init() -> void:
	effect_callback_type = CompositorEffect.EFFECT_CALLBACK_TYPE_POST_TRANSPARENT
	rendering_device = RenderingServer.get_rendering_device()
		
	_load_toon_shader()
	
func _load_toon_shader() -> void: 
	if !rendering_device:
		print("Unable to get RenderingDevice from RenderingServer.")
		return
	if(!toon_shader_file):
		print("Toon shader file not provided.")
		return
	var toon_shader_spirv: RDShaderSPIRV = toon_shader_file.get_spirv()
	toon_shader = rendering_device.shader_create_from_spirv(toon_shader_spirv)
	compute_pipeline = rendering_device.compute_pipeline_create(toon_shader)

func _render_callback(ParameterEffectCallbackType: int, parameter_render_data: RenderData) -> void:
	if(ParameterEffectCallbackType != effect_callback_type || !rendering_device || !compute_pipeline.is_valid()):
		return
		
	var render_scene_buffers: RenderSceneBuffersRD = parameter_render_data.get_render_scene_buffers()
	if !render_scene_buffers:
		print("Unable to get render scene buffers.")
		return
		
	var render_scene_buffers_size = render_scene_buffers.get_internal_size()
	if(render_scene_buffers_size.x == 0 || render_scene_buffers_size.y == 0):
		return
	
	var target_render_image := render_scene_buffers.get_color_layer(0)
	
	if(target_render_image != cached_texture_rid || !cached_uniform_set):
		cached_texture_rid = target_render_image
		
		var uniform_set := RDUniform.new()
		uniform_set.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
		uniform_set.binding = 0
		uniform_set.add_id(target_render_image)

		cached_uniform_set = rendering_device.uniform_set_create([uniform_set], toon_shader, 0)
		
	var compute_list := rendering_device.compute_list_begin()
	rendering_device.compute_list_bind_compute_pipeline(compute_list, compute_pipeline)
	rendering_device.compute_list_bind_uniform_set(compute_list, cached_uniform_set, 0)

	var x_warp_group_size := int(ceil(render_scene_buffers_size.x / 8))
	var y_warp_group_size := int(ceil(render_scene_buffers_size.y / 8))
	rendering_device.compute_list_dispatch(compute_list, x_warp_group_size, y_warp_group_size, 1)

	rendering_device.compute_list_end()
