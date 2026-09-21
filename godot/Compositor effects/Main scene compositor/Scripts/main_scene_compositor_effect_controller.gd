@tool
class_name CompositorEffectController
extends CompositorEffect

var rendering_device: RenderingDevice

var cached_uniform_set: RID
var cached_texture_rid: RID

var compute_pipeline: RID

'''
So main idea is:
	- we inherit from the base class to make callable, small implementations of effects that have their own specific logic
	
	- we have implementation functions like this file that simply call those inherited objects so that they can do their own custom effect processing logic. 
		pros: easily debuggable and reviewable
		cons: not as easy to understand or implement compared to node based or duck typed composition
	
'''

func _init() -> void:
	effect_callback_type = CompositorEffect.EFFECT_CALLBACK_TYPE_POST_TRANSPARENT
	rendering_device = RenderingServer.get_rendering_device()
	
func _render_callback(ParameterEffectCallbackType: int, ParameterRenderData: RenderData) -> void:
	if(ParameterEffectCallbackType != effect_callback_type || !rendering_device || !compute_pipeline.is_valid()):
		return
		
	var render_scene_buffers: RenderSceneBuffersRD = ParameterRenderData.get_render_scene_buffers()
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
